var mymap = L.map('mapid').setView([51.505, -0.09], 13);

var r = 10.0;
var t = 0.0;

function setup() {
    createCanvas(640, 480);
}

function draw() {

    if (mouseIsPressed) {
        fill(0);
    } else {
        fill(255);
    }

    r = r + 5.0 * sin(t);

    ellipse(mouseX, mouseY, r, r);

    t += 0.1;
}
