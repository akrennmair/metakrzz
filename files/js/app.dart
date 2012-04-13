#import('dart:html');
#import('dart:json');

class Shortener {
	Controller ctrl;
	var shorteners;

	Shortener() {
		this.ctrl = null;
		// add more shorteners here; TODO: add 'googl' as soon as IO::Socket::SSL is available
		this.shorteners = [ 'krzz', 'tinyurl', 'isgd', 'bitly', 'jmp', 'b23ru', 'cortas', 'kortanu', 'redirec', 'ipirat', 'yepit', 'chilpit', 'migreme' ];
	}

	void set controller(Controller c) {
		this.ctrl = c;
	}

	void shorten(String url) {
		this.shorteners.forEach((id) {
			ShortenerRequest req = new ShortenerRequest(this.ctrl, id, url);
			req.run();
		});
	}

	int getShortenerCount() {
		return this.shorteners.length;
	}
}

class ShortenerRequest {
	String id;
	String url;
	Controller ctrl;

	ShortenerRequest(this.ctrl, this.id, this.url);

	void run() {
		XMLHttpRequest xhr = new XMLHttpRequest();
		xhr.open("GET", "/shorten/" + this.id + "?url=" + this.url, true);

		xhr.on.load.add((event) {
			print("got load for $id");
			this.ctrl.receivedResult();
			if (xhr.status != 200) {
				print("error: " + xhr.responseText);
				this.ctrl.showError("shortener returned " + xhr.status);
				return;
			}
			Map<String, Object> msg = JSON.parse(xhr.responseText);
			if (msg["error"] != null) {
				this.ctrl.showError(msg["error"]);
				print(msg["error"]);
			} else {
				this.ctrl.addShortURL(msg["url"]);
			}
		});

		xhr.send();
	}
}

class Controller {
	UI ui_;
	Shortener sh;

	Controller() {
		this.ui_ = null;
		this.sh = null;
	}

	void set ui(UI u) {
		this.ui_ = u;
	}

	void set shortener(Shortener s) {
		this.sh = s;
	}

	void shorten(String url) {
		this.sh.shorten(url);
	}

	int getShortenerCount() {
		return this.sh.getShortenerCount();
	}

	void addShortURL(String url) {
		this.ui_.addShortURL(url);
	}

	void showError(String err) {
		this.ui_.showError(err);
	}

	void receivedResult() {
		this.ui_.receivedResult();
	}
}

class UI {
	Controller ctrl;
	int total_results;
	int received_results;

	UI() {
		this.ctrl = null;
		this.total_results = 0;
		this.received_results = 0;
	}

	void set controller(Controller c) {
		this.ctrl = c;
	}

	void showError(String msg) {
		DivElement errmsg = document.query('#errmsgbox');
		errmsg.innerHTML = '<a id="errmsgclose" class="close" data-dismiss="alert">&times;</a><h4>Error:</h4>$msg';
		errmsg.style.display = "inline";
		document.query('#errmsgclose').on.click.add( (e) => errmsg.style.display = "none" );
	}

	void receivedResult() {
		this.received_results++;

		if (this.received_results == this.total_results) {
			document.query('#recvmsg').style.display = "none";
			print("deactivated recvmsg");
		}
	}

	void buttonClicked() {
		InputElement url_input = document.query('#url');
		if (!url_input.checkValidity()) {
			this.showError("Invalid URL");
			return;
		}

		this.total_results = this.ctrl.getShortenerCount();
		this.received_results = 0;

		document.query('#recvmsg').style.display = "inline";
		print("activated recvmsg");

		TableElement tbl = document.query('#urltbl');
		tbl.style.display = "inline";
		print("showing urltbl");

		// clear table:
		for (int i=tbl.rows.length-1;i>0;i--) {
			tbl.deleteRow(i);
		}

		String url = url_input.value;

		this.ctrl.shorten(url);
	}

	void addShortURL(String url) {
		TableElement tbl = document.query('#urltbl');

		TableRowElement new_row = tbl.insertRow(tbl.rows.length);

		TableCellElement urlfield = new Element.html('<td><a href="${url}">${url}</a></td>');
		new_row.nodes.add(urlfield);

		TableCellElement lenfield = new Element.tag('td');
		lenfield.text = '${url.length} characters';
		new_row.nodes.add(lenfield);
	}
}

void main() {
	UI ui = new UI();
	Controller ctrl = new Controller();
	Shortener sh = new Shortener();

	ui.controller = ctrl;
	sh.controller = ctrl;

	ctrl.ui = ui;
	ctrl.shortener = sh;

	window.on.contentLoaded.add( (e) {
			document.query('#btn').on.click.add( (event) {
				event.preventDefault();
				ui.buttonClicked();
			});
		}
	);
}
