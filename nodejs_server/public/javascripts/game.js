var stage;
var loaderAssets = [];
var canvas, container;
var ball, grass, target;

var configuration = {
	SPEED_MULTIPLIER : 6,
	MINIMUM_SPEED : 3,
	DURATION_MULTIPLIER : 0.005
};

var state = {
	ballOffsetX : 0,
	ballOffsetY : 0,
	ballStartX : 0,
	ballStartY : 0,
	prevX : 0,
	prevY : 0,
	velX : 0,
	velY : 0,
	speed : 0,
	angle: 0,
	distance: 0,
	distanceX: 0,
	distanceY: 0,
	animation: 0
};

window.onresize = resize;

function resize() {
	canvas.width = window.innerWidth < 1280 ? window.innerWidth : 1280;
	canvas.height = window.innerHeight < 1280 ? window.innerHeight : 1280;
}

function init() {
	canvas = document.getElementById("game");
	stage = new createjs.Stage(canvas);
	stage.autoClear = false;

	loader = new PreloadJS();
	loader.onFileLoad = onLoaderFileLoad;
	loader.onComplete = onLoaderComplete;
	loader.loadManifest([
		{src:"images/ball.png", id:"ball"},
		{src:"images/grass.png", id:"grass"}
		]);
	resize();
}

function tick() {


	stage.update();
}

function onLoaderFileLoad(file) {
	loaderAssets.push(file);
}

function onLoaderComplete() {
	for(var i=0;i<loaderAssets.length;i++) {
		var item = loaderAssets[i];
		var id = item.id;
		var result = item.result;

		switch (id) {
			case "ball":
			createBall(result);
			break;
			case "grass":
			createGrass(result);
			break;
		}
	}

	createTarget();

	loaderAssets = null;

	createjs.Ticker.addListener(window);
	createjs.Touch.enable(stage);
}

function createBall(result) {
	ball = new createjs.Bitmap(result);
	ball.regX = ball.image.width/2|0;
	ball.regY = ball.image.height/2|0;
	ball.x = canvas.width / 2;
	ball.y = canvas.height / 2;
	ball.scaleX = ball.scaleY = 1;
	ball.grabbed = false;
	ball.onPress = onBallPress;

	stage.addChild(ball);
}

function createGrass(result) {
	grass = new createjs.Shape();
	var g = grass.graphics;
	g.beginBitmapFill(result);
	g.drawRect(0, 0, canvas.width, canvas.height);

	stage.addChildAt(grass, 0);
}

function createTarget() {
	target = new createjs.Shape();
	var g = target.graphics;
	g.beginFill("transparent");
	g.drawCircle(0, 0, 6);
	g.endFill();

	target.x = canvas.width / 2;
	target.y = canvas.height / 2;

	stage.addChild(target);
}

function onBallPress(event) {
	TweenLite.killTweensOf(ball);

	state.ballOffsetX = ball.x - event.stageX;
	state.ballOffsetY = ball.y - event.stageY;

	ball.grabbed = true;
	//ball.scaleX = ball.scaleY = 1;

	state.ballStartX = ball.x;
	state.ballStartY = ball.y;

	event.onMouseMove = onBallMouseMove;
	event.onMouseUp = onBallMouseUp;
}

function onBallMouseMove(event) {
	ball.x = event.stageX + state.ballOffsetX;
	ball.y = event.stageY + state.ballOffsetY;

	state.velX = event.stageX - state.prevX;
	state.velY = event.stageY - state.prevY;
	state.speed = Math.abs(state.velX) + Math.abs(state.velY);
	state.speed = state.speed > configuration.MINIMUM_SPEED ? state.speed * configuration.SPEED_MULTIPLIER : 0;

	state.prevX = event.stageX;
	state.prevY = event.stageY;

	//console.log(state.speed);
}

function onBallMouseUp(event) {
	ball.grabbed = false;
	//ball.scaleX = ball.scaleY = 0.8;

	if (state.ballStartX !== ball.x && state.ballStartY !== ball.y) {

		target.x = ball.x;
		target.y = ball.y;

		state.angle = Math.atan2((ball.y + state.velY) - ball.y, (ball.x + state.velX) - ball.x);

		target.x += Math.cos(state.angle) * state.speed;
		target.y += Math.sin(state.angle) * state.speed;

		state.distanceX = ball.x - target.x;
		state.distanceY = ball.y - target.y;
		state.distance = Math.sqrt(state.distanceX * state.distanceX + state.distanceY * state.distanceY);

		TweenLite.to( ball, (state.distance * configuration.DURATION_MULTIPLIER), {x: target.x, y: target.y, ease:Expo.easeOut});
	}
}


