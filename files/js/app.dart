#import('dart:html');
#import('dart:json');

class UI {

	var shorteners;
	
	UI() {
		this.shorteners = [ 'googl', 'tinyurl' ];
	}

	void showError(String msg) {
		DivElement errmsg = document.query('#errmsgbox');
		errmsg.innerHTML = '<a id="errmsgclose" class="close" data-dismiss="alert">&times;</a><h4>Error:</h4>$msg';
		errmsg.style.display = "inline";
		document.query('#errmsgclose').on.click.add( (e) => errmsg.style.display = "none" );
	}

	void buttonClicked() {
		InputElement url_input = document.query('#url');
		if (!url_input.checkValidity()) {
			showError("Invalid URL");
			return;
		}

		int results_open = shorteners.length;
		document.query('#recvmsg').style.display = "inline";
		print("activated recvmsg");

		TableElement tbl = document.query('#urltbl');
		tbl.style.display = "inline";
		print("showing urltbl");
		// TODO: empty table beforehand

		String url = url_input.value;

		shorteners.forEach((id) {
			print("id = $id");
			XMLHttpRequest xhr = new XMLHttpRequest();
			xhr.open("GET", "/shorten/" + id + "?url=" + url, true);

			xhr.on.load.add((event) {
				print("got load for $id");
				if (xhr.status != 200) {
					print("error: " + xhr.responseText);
					showError("shortener returned " + xhr.status);
					return;
				}
				Map<String, Object> msg = JSON.parse(xhr.responseText);
				if (msg["error"] != null) {
					showError(msg["error"]);
					print(msg["error"]);
				} else {
					String url = msg["url"];

					TableRowElement new_row = tbl.insertRow(tbl.rows.length);

					TableCellElement urlfield = new Element.html('<td><a href="${url}">${url}</a></td>');
					new_row.nodes.add(urlfield);

					TableCellElement lenfield = new Element.tag('td');
					lenfield.text = '${url.length} characters';
					new_row.nodes.add(lenfield);

					results_open--;

					print("results_open = $results_open");

					if (results_open == 0) {
						document.query('#recvmsg').style.display = "none";
						print("deactviated recvmsg");
					}
				}
			});

			xhr.send();
			print("sent request for $id");
		});
	}
}

void main() {
	UI ui = new UI();
	window.on.contentLoaded.add( (e) {
			document.query('#btn').on.click.add( (event) {
				event.preventDefault();
				ui.buttonClicked();
			});
		}
	);
}
