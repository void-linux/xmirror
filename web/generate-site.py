#!/usr/bin/python3

import csv
import json
import re
from pathlib import Path
from shutil import copytree, rmtree
from sys import argv, stderr

import yaml


tabletmpl = """
<table>
<thead>
<tr>
  <th>Mirror</th>
  <th>Region</th>
  <th>Location</th>
</tr>
</thead>
<tbody>
{rows}
</tbody>
</table>
"""

rowtmpl = """<tr>
  <td><a href="{url}">{url}</a></td>
  <td>{region}</td>
  <td>{location}</td>
</tr>
"""


regions = {
	"AF": "Africa",
	"AN": "Antarctica",
	"AS": "Asia",
	"EU": "Europe",
	"NA": "North America",
	"OC": "Oceania",
	"SA": "South and Central America",
	"World": "Globally Available",
}


def write_api(destdir: Path, data: list[dict]):
	apidir = destdir / "v0"
	apidir.mkdir(parents=True)
	with (apidir / "mirrors.json").open("w") as f:
		json.dump(data, f)


def write_metrics(destdir: Path, data: list[dict]):
	"""
	generate files for assessing mirror status with prometheus
	"""
	def prom_targets(data: list[dict]) -> list[dict]:
		"""
		transforms the mirror list into a prometheus target list format
		https://prometheus.io/docs/prometheus/latest/http_sd/
		"""
		tgts = sorted(re.sub(r"^(?:http|ftp)s?://(.*?)/?$", r"\1/current", m["base_url"]) for m in data)
		return [{"targets": tgts}]

	metricsdir = destdir / "metrics"
	metricsdir.mkdir(parents=True)
	promdata = prom_targets(data)
	with (metricsdir / "prometheus.json").open("w") as f:
		json.dump(promdata, f)

def write_raw(destdir: Path, data: list[dict]):
	"""
	generate the tab-separated value file for bash xmirror
	"""
	rawdir = destdir / "raw"
	rawdir.mkdir(parents=True)
	with (rawdir / "mirrors.lst").open("w") as f:
		wr = csv.writer(f, dialect="excel-tab")
		wr.writerows([[m["region"], m["base_url"], m["location"], m["tier"]] for m in data if m["enabled"]])


def write_html(html: str, destdir: Path, data: list[dict]):
	"""
	write the list of mirrors into 2 tables, one for each tier, and insert them in the html document
	"""
	def reg(r: str) -> str:
		"""get a pretty name for a region"""
		if r in regions.keys():
			return regions[r]
		return r

	tier1 = tabletmpl.format(rows="\n".join(
		[rowtmpl.format(url=m["base_url"], region=reg(m["region"]), location=m["location"])
			for m in data if m["tier"] == 1 and m["enabled"]]
	))
	tier2 = tabletmpl.format(rows="\n".join(
		[rowtmpl.format(url=m["base_url"], region=reg(m["region"]), location=m["location"])
			for m in data if m["tier"] == 2 and m["enabled"]]
	))
	with (destdir / "index.html").open("w") as f:
		f.write(html.format(tier1=tier1, tier2=tier2))


if __name__ == "__main__":
	if len(argv) != 2:
		print(f"usage: {argv[0]} <destdir>", file=stderr)
		raise SystemExit(1)

	destdir = Path(argv[1])
	if destdir.exists() and not destdir.is_dir():
		print(f"{argv[0]}: {destdir} exists but is not a directory", file=stderr)
		print(f"usage: {argv[0]} <destdir>", file=stderr)
		raise SystemExit(1)

	srcfile = Path("mirrors.yaml")
	if not srcfile.is_file():
		print(f"{argv[0]}: {srcfile} does not exist or is not a file", file=stderr)
		raise SystemExit(1)

	htmlfile = Path("web/index.html.in")
	if not htmlfile.is_file():
		print(f"{argv[0]}: {htmlfile} does not exist or is not a file", file=stderr)
		raise SystemExit(1)

	assetdir = Path("web/assets")
	if not assetdir.exists():
		print(f"{argv[0]}: {assetdir} does not exist", file=stderr)
		raise SystemExit(1)
	elif assetdir.exists() and not assetdir.is_dir():
		print(f"{argv[0]}: {assetdir} exists but is not a directory", file=stderr)
		raise SystemExit(1)

	# clean up
	if destdir.exists():
		rmtree(destdir)

	# load data
	with srcfile.open() as f:
		data = yaml.safe_load(f.read())

	# write v0 api json
	write_api(destdir, data)

	# write prometheus json
	write_metrics(destdir, data)

	# write raw tsv data
	write_raw(destdir, data)

	with htmlfile.open() as f:
		html = f.read()

	# write html table
	write_html(html, destdir, data)

	# copy site assets
	copytree(assetdir, destdir / "assets")
