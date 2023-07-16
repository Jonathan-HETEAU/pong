package pong;

import hxd.Key;
import h2d.Object;

class Ball extends Object {
	public var radius:Int;
	public var speed:Float;
	public var rotated:Float;
	public var acceleration:Float;

	public function new(?parent:Object, x:Float, y:Float) {
		super(parent);
		this.x = x;
		this.y = y;
		this.radius = 10;
		this.speed = 200;
		this.acceleration = 1.5;
		this.rotated = 0;

        var g = new h2d.Graphics(this);
        g.beginFill(0xFFFFFF);
		g.drawCircle(0,0, this.radius);
        g.beginFill(0x000000);
        g.drawCircle(0,0, this.radius - 2);
		g.endFill();
        
	}
    

    public function upate (dt:Float) {
        this.move(this.speed * dt,0);   
    }

	public function collideWithPaddle(paddle:Paddle) {
		if (this.x - this.radius < paddle.x + paddle.width / 2 && this.x + this.radius > paddle.x - paddle.width / 2) {
			if (this.y - this.radius < paddle.y + paddle.height / 2 && this.y + this.radius > paddle.y - paddle.height / 2) {
				this.speed *= this.acceleration;
				this.rotated = (this.y - paddle.y) / (paddle.height / 2);
				this.rotated *= Math.PI / 4;
				this.rotated = Math.max(-Math.PI / 4, Math.min(this.rotated, Math.PI / 4));
				
			}
		}
	}
}

class Paddle extends Object {
	public var width:Int;
	public var height:Int;
	public var speed:Float;
	public var inputPad:InputPad;

	public function new(?parent:Object, x:Float, y:Float,inputPad:InputPad) {
		super(parent);
		this.x = x;
		this.y = y;
		this.width = 20;
		this.height = 100;
		this.speed = 400;
		this.inputPad = inputPad;

		

        var g = new h2d.Graphics(this);
        g.beginFill(0xFFFFFF);
		g.drawRect(  - this.width/2 ,  - this.height / 2 , this.width, this.height);
        g.endFill();
	}

	public function update(dt:Float) {
		if (inputPad.isUpPressed()) {
			this.y  -= this.speed * dt;
		}
		if (inputPad.isDownPressed()) {
			this.y  += this.speed * dt;
		}

		this.y = Math.max(this.height / 2, Math.min(this.y, Main.HEIGHT - this.height / 2));
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
		if(Key.isDown(keyUp)){
			trace(Std.string(keyUp)+ "is pressed");
			return true;
		}
		return false;
	}
	
	public function isDownPressed() {
		if(Key.isDown(keyDown)){
			trace(Std.string(keyDown)+ "is pressed");
			return true;
		}
		return false;
	}
}

class Arena extends Object {
	public var width:Int;
	public var height:Int;
    
	public function new(?parent:Object, width:Int, height:Int) {
        super(parent);
        this.setPosition(0,0);
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

    public static final WIDTH : Int = 800;
    public static final HEIGHT: Int = 600;

    public var arena:Arena;
    public var ball:Ball;
    public var paddles:Array<Paddle>;
    
	override function init() {
        arena = new Arena(s2d ,WIDTH, HEIGHT);
        ball = new Ball(arena, WIDTH / 2, HEIGHT / 2);
		paddles = [
			new Paddle(s2d, WIDTH * 0.05, HEIGHT / 2, new InputPad(Key.Z, Key.S)),
			new Paddle(s2d, WIDTH * 0.95, HEIGHT / 2, new InputPad(Key.UP, Key.DOWN))
		];
	}

	override function update(dt:Float) {
		super.update(dt);
        ball.upate(dt);
		paddles[0].update(dt);
		paddles[1].update(dt);
		ball.collideWithPaddle(paddles[0]);
		ball.collideWithPaddle(paddles[1]);
	}

	function getKeyName(id) {
		var name = hxd.Key.getKeyName(id);
		if( name == null ) name = "#"+id;
		return name;
	}

	static function main() {
		new Main();
	}
}
