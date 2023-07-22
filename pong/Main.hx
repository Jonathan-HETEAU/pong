package pong;

import h2d.col.Circle;
import hxd.Key;
import h2d.Object;

class Ball extends Object {
	public var radius:Int;
	public var speed:Float;
	public var acceleration:Float;
	public var normalSpeed:Vec2;

	public function new(?parent:Object, x:Float, y:Float) {
		super(parent);
		setPosition(x, y);
		this.radius = 10;
		this.speed = 200;
		this.acceleration = 20;
		this.normalSpeed = new Vec2(1,0);

		var g = new h2d.Graphics(this);
		g.beginFill(0xFFFFFF);
		g.drawCircle(0, 0, this.radius);
		g.beginFill(0x000000);
		g.drawCircle(0, 0, this.radius - 2);
		g.endFill();
	}

	public function restart() {
		this.normalSpeed = new Vec2(1,0);
		this.speed = 200;
	}

	public function update(dt:Float) {
		this.x += this.normalSpeed.x * this.speed * dt;
		this.y += this.normalSpeed.y * this.speed * dt;
	}
}

class Paddle extends Object {
	public var width:Int;
	public var height:Int;
	public var speed:Float;
	public var inputPad:InputPad;

	public function new(?parent:Object, x:Float, y:Float, inputPad:InputPad) {
		super(parent);
		this.setPosition(x, y);
		this.width = 20;
		this.height = 100;
		this.speed = 400;
		this.inputPad = inputPad;

		var g = new h2d.Graphics(this);
		g.beginFill(0xFFFFFF);
		g.drawRect(-this.width / 2, -this.height / 2, this.width, this.height);
		g.endFill();
	}

	public function update(dt:Float) {
		if (inputPad.isUpPressed()) {
			this.y -= this.speed * dt;
		}
		if (inputPad.isDownPressed()) {
			this.y += this.speed * dt;
		}
	}
}

class InputPad {
	public var keyUp:Int;
	public var keyDown:Int;

	public function new(keyUp:Int, keyDown:Int) {
		this.keyUp = keyUp;
		this.keyDown = keyDown;
	}

	public function isUpPressed() {
		return Key.isDown(keyUp);
	}

	public function isDownPressed() {
		return Key.isDown(keyDown);
	}
}

class Arena extends Object {
	public var width:Float;
	public var height:Float;

	public function new(?parent:Object, width:Float, height:Float) {
		super(parent);
		this.setPosition(0, 0);
		this.width = width;
		this.height = height;
		var g = new h2d.Graphics(this);
		g.beginFill(0xFFFFFF);
		g.drawRect(0, 0, this.width, this.height);
		g.beginFill(0x000000);
		g.drawRect(2, 2, this.width - 4, this.height - 4);
		g.beginFill(0xFFFFFF);
		g.drawRect(this.width / 2 - 2, 0, 4, this.height);
		g.endFill();
	}
}

class Main extends hxd.App {
	public static final WIDTH:Int = 800;
	public static final HEIGHT:Int = 600;

	public var arena:Arena;
	public var ball:Ball;
	public var paddles:Array<Paddle>;

	override function init() {
		arena = new Arena(s2d, WIDTH, HEIGHT);
		ball = new Ball(arena, WIDTH / 2, HEIGHT / 2);
		paddles = [
			new Paddle(arena, WIDTH * 0.05, HEIGHT / 2, new InputPad(Key.Z, Key.S)),
			new Paddle(arena, WIDTH * 0.95, HEIGHT / 2, new InputPad(Key.UP, Key.DOWN))
		];
	}

	override function update(dt:Float) {
		super.update(dt);
		ball.update(dt);
		updatePaddles(dt);
		updateCollision();
	}
	function updatePaddles(dt:Float) {
		for(paddle in paddles) {
			paddle.update(dt);

			if (paddle.y < paddle.height / 2) {
				paddle.y = paddle.height / 2;
			}
			if (paddle.y > HEIGHT - paddle.height / 2) {
				paddle.y = HEIGHT - paddle.height / 2;
			}
		}
	}
	function updateCollision() {
		var ballCircle = new Circle(ball.x, ball.y, ball.radius);

		var arenaBounds = h2d.col.Bounds.fromValues(arena.x + ball.radius, arena.y + ball.radius, arena.width - ball.radius - ball.radius, arena.height - ball.radius - ball.radius);

		if (!ballCircle.collideBounds(arenaBounds)) {
			if(ballCircle.y < arenaBounds.y) {
				ball.normalSpeed.y = -ball.normalSpeed.y;
			}
			if(ballCircle.y > arenaBounds.y + arenaBounds.height) {
				ball.normalSpeed.y = -ball.normalSpeed.y;
			}
			if (ballCircle.x < arenaBounds.x) {
				trace("left player wins");
				ball.setPosition(WIDTH / 2, HEIGHT / 2);
			}
			if (ballCircle.x > arenaBounds.x + arenaBounds.width) {
				trace("right player wins");
				ball.setPosition(WIDTH / 2, HEIGHT / 2);
			}
		}

		for(paddle in paddles) {
			var paddleBounds = h2d.col.Bounds.fromValues(paddle.x - paddle.width / 2, paddle.y - paddle.height / 2, paddle.width, paddle.height);
			if (ballCircle.collideBounds(paddleBounds)) {
				var modification = (ball.y - paddle.y) / (paddle.height / 2);
				if(ball.normalSpeed.x < 0){
					ball.setPosition(paddle.x + paddle.width / 2 + ball.radius, ball.y);
				}else{
					ball.setPosition(paddle.x - paddle.width / 2 - ball.radius, ball.y);
				}
				ball.normalSpeed.y = modification + ball.normalSpeed.y;
				ball.normalSpeed.x = -ball.normalSpeed.x;
				var long = Math.sqrt(ball.normalSpeed.x * ball.normalSpeed.x + ball.normalSpeed.y * ball.normalSpeed.y);
				ball.normalSpeed.x /= long;
				ball.normalSpeed.y /= long;
				ball.speed += ball.acceleration;
			}
		}
	}

	function getKeyName(id) {
		var name = hxd.Key.getKeyName(id);
		if (name == null)
			name = "#" + id;
		return name;
	}

	static function main() {
		new Main();
	}
}
