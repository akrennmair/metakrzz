#import('dart:html');

class UI {
	int count = 0;

	buttonClicked() {
		print('click ' + this.count + '!');
		this.count++;
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
