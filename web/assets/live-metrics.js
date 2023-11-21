function parseAge(age) {
  if (!age) {
    return { className: "time-muted", innerText: "unreachable" };
  }

  const days = `${(age / (24 * 60 * 60)).toFixed(1)} days`;
  const hours = `${(age / (60 * 60)).toFixed(1)} hours`;
  const minutes = `${(age / 60).toFixed(0)} minutes`;
  if (age >= 20 * 24 * 60 * 60) {
    // 20 days
    return { className: "time-muted", innerText: "a long time ago" };
  } else if (age >= 24 * 60 * 60) {
    // 24 hours
    return { className: "time-red", innerText: days };
  } else if (age >= 19 * 60 * 60) {
    // 19 hours
    return { className: "time-yellow", innerText: hours };
  } else if (age >= 60 * 60) {
    // 1 hour
    return { className: "time-green", innerText: hours };
  } else {
    // less than an hour
    return { className: "time-green", innerText: minutes };
  }
}

document.addEventListener("DOMContentLoaded", async () => {
  const req = await fetch(
    "https://prometheus.voidlinux.org/api/v1/query?query=(time()-repo_origin_time%7Bzone=%22external%22%7D)"
  );
  const data = await req.json();

  const mirrorAge = Object.fromEntries(
    data["data"]["result"].map((val) => {
      const url = val["metric"]["instance"].replace(/current$/, "");
      const age = parseFloat(val["value"][1]);
      return [url, age];
    })
  );

  const headerRows = document.querySelectorAll(".mirrortbl > thead > tr");
  for (const headerRow of headerRows) {
    const header = document.createElement("th");
    header.innerText = "Last Synced";
    headerRow.appendChild(header);
  }

  const rows = document.querySelectorAll(".mirrortbl > tbody > tr");
  for (const row of rows) {
    const url = row
      .querySelector("a")
      .getAttribute("href")
      .replace(/https?:\/\//, "");
    const { className, innerText } = parseAge(mirrorAge[url]);

    const cell = document.createElement("td");
    cell.className = className;
    cell.innerText = innerText;
    row.appendChild(cell);
  }
});
