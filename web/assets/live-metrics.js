function parseAge(raw) {
	var v = parseFloat(raw);
	if (v >= 20*24*60*60) { // 20 days
		return '<td class="time-muted">a long time ago</td>';
	} else if (v >= 24*60*60) { // 24 hours
		return '<td class="time-red">' + (v/(24*60*60)).toFixed(1) + " days</td>"
	} else if (v >= 19*60*60) { // 19 hours
		return '<td class="time-yellow">' + (v/(60*60)).toFixed(1) + " hours</td>"
	} else if (v >= 60*60) { // 1 hour
		return '<td class="time-green">' + (v/(60*60)).toFixed(1) + " hours</td>"
	} else { // less than an hour
		return '<td class="time-green">' + (v/60).toFixed(0) + " minutes</td>"
	}
}

$(function() {
	$.getJSON(
		"https://prometheus.voidlinux.org/api/v1/query?query=(time()-repo_origin_time%7Bzone=%22external%22%7D)",
		function(data) {
			var mirrors = {};
			$.each(data["data"]["result"], function(i, val) {
				mirrors[val["metric"]["instance"].replace(/current$/, "")] = parseAge(val["value"][1]);
			});
			console.log(mirrors);
			$(".mirrortbl thead tr").append('<th>Last Synced</th>');
			$(".mirrortbl tbody tr").each(function() {
				var k = $(this).children(":first")[0].innerText.trim().replace(/https?:\/\//, "");
				$(this).append(mirrors[k] || '<td class="time-muted">unreachable</td>');
			});
		}
	);
});

