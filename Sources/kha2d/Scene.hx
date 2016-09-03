package kha2d;

import haxe.ds.ArraySort;
import kha.Color;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import kha.math.Matrix3;
import kha.math.Vector2;

class Scene {
	var collisionLayer: CollisionLayer;
	var backgrounds : Array<Tilemap>;
	var foregrounds : Array<Tilemap>;
	var backgroundSpeeds : Array<Float>;
	var foregroundSpeeds : Array<Float>;
	var sprites : Array<Sprite>;	
	var backgroundColor : Color;
	
	var width: Int = 640;
	var height: Int = 480;
	
	public var cameraX(default, set): Int;
	public var cameraY(default, set): Int;
	public var screenOffsetX: Int;
	public var screenOffsetY: Int;
	
	var dirtySprites: Bool = false;
	
	public function new( width : Int, height : Int ) {
		sprites = new Array<Sprite>();
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
		backgroundColor = Color.fromBytes(0, 0, 0);
		cameraX = 0;
		cameraY = 0;
		setSize(width, height);
	}
	
	public function setSize(width: Int, height: Int): Void {
		this.width = width;
		this.height = height;
	}
	
	public function clear() {
		collisionLayer = null;
		clearTilemaps();
		sprites = new Array<Sprite>();
	}
	
	public function clearTilemaps() {
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
	}
	
	public function setBackgroundColor(color : Color) {
		backgroundColor = color;
	}

	public function addBackgroundTilemap(tilemap : Tilemap, speed : Float) {
		backgrounds.push(tilemap);
		backgroundSpeeds.push(speed);
	}
	
	public function addForegroundTilemap(tilemap : Tilemap, speed : Float) {
		foregrounds.push(tilemap);
		foregroundSpeeds.push(speed);
	}
	
	public function setColissionMap(tilemap: Tilemap) {
		collisionLayer = new CollisionLayer(tilemap);
	}
	
	public function addHero(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addHero(sprite);
		sprites.push(sprite);
	}
	
	public function addEnemy(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addEnemy(sprite);
		sprites.push(sprite);
	}
	
	public function addProjectile(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addProjectile(sprite);
		sprites.push(sprite);
	}
	
	public function addOther(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addOther(sprite);
		sprites.push(sprite);
	}

	public function removeHero(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
	}
	
	public function removeEnemy(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
	}
	
	public function removeProjectile(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
	}
	
	public function removeOther(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
	}
	
	public function getHero(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getHero(index);
	}
	
	public function getEnemy(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getEnemy(index);
	}
	
	public function getProjectile(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getProjectile(index);
	}
	
	public function getOther(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getOther(index);
	}
	
	public function countHeroes(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countHeroes();
	}
	
	public function countEnemies(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countEnemies();
	}

	public function countProjectiles(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countProjectiles();
	}

	public function countOthers(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countOthers();
	}
	
	function set_cameraX(newcamx: Int): Int {
		cameraX = newcamx;
		if (collisionLayer != null) {
			screenOffsetX = Std.int(Math.min(Math.max(0, cameraX - width / 2), collisionLayer.getMap().levelWidth * collisionLayer.getMap().tileset.TILE_WIDTH - width));
			if (getWidth() < width) screenOffsetX = 0;
		}
		else screenOffsetX = cameraX;
		return cameraX;
	}
	
	function set_cameraY(newcamy: Int): Int {
		cameraY = newcamy;
		if (collisionLayer != null) {
			screenOffsetY = Std.int(Math.min(Math.max(0, cameraY - height / 2), collisionLayer.getMap().levelHeight * collisionLayer.getMap().tileset.TILE_HEIGHT /*+ camyHack*/ - height));
			if (getHeight() < height) screenOffsetY = 0;
		}
		else screenOffsetY = cameraY;
		return cameraY;
	}
	
	function sort(sprites : Array<Sprite>) {
		if (sprites.length == 0) return;
		ArraySort.sort(sprites, function(arg0: Sprite, arg1: Sprite) {
			if (arg0.x < arg1.x) return -1;
			else if (arg0.x == arg1.x) return 0;
			else return 1;
		});
	}
	
	public function collidesPoint(point: Vector2): Bool {
		return collisionLayer != null && collisionLayer.collidesPoint(point);
	}
	
	public function collidesSprite(sprite: Sprite): Bool {
		return collisionLayer != null && collisionLayer.collidesSprite(sprite);
	}
	
	private function cleanSprites(): Void {
		if (!dirtySprites) return;
		var found = true;
		while (found) {
			found = false;
			for (sprite in sprites) {
				if (sprite.removed) {
					sprites.remove(sprite);
					found = true;
				}
			}
		}
		if (collisionLayer != null) collisionLayer.cleanSprites();
	}
	
	public function update(): Void {
		cleanSprites();
		if (collisionLayer != null) {
			collisionLayer.advance(screenOffsetX, screenOffsetX + width);
		}
		cleanSprites();
		for (sprite in sprites) sprite.update();
		cleanSprites();
	}

	// TODO (DK) all transform stuff needs to be relative so it can be offset'ed as well
	// TODO (DK) remove clear()?
	public function render(g: Graphics) {
		g.transformation = FastMatrix3.identity();
		g.color = backgroundColor;
		g.clear();
		
		for (i in 0...backgrounds.length) {
			g.transformation = FastMatrix3.translation(Math.round(-screenOffsetX * backgroundSpeeds[i]), Math.round(-screenOffsetY * backgroundSpeeds[i]));
			backgrounds[i].render(g, Std.int(screenOffsetX * backgroundSpeeds[i]), Std.int(screenOffsetY * backgroundSpeeds[i]), width, height);
		}
		
		g.transformation = FastMatrix3.translation(-screenOffsetX, -screenOffsetY);
		
		sort(sprites);
		
		for (z in 0...10) {
			var i : Int = 0;
			while (i < sprites.length) {
				if (sprites[i].x + sprites[i].width > screenOffsetX) break;
				++i;
			}
			while (i < sprites.length) {
				if (sprites[i].x > screenOffsetX + width) break;
				if (i < sprites.length && sprites[i].z == z) sprites[i].render(g);
				++i;
			}
		}
		
		for (i in 0...foregrounds.length) {
			g.transformation = FastMatrix3.translation(Math.round(-screenOffsetX * foregroundSpeeds[i]), Math.round(-screenOffsetY * foregroundSpeeds[i]));
			foregrounds[i].render(g, Std.int(screenOffsetX * foregroundSpeeds[i]), Std.int(screenOffsetY * foregroundSpeeds[i]), width, height);
		}
	}
	
	public function getWidth() : Float {
		if (collisionLayer != null) return collisionLayer.getMap().levelWidth * collisionLayer.getMap().tileset.TILE_WIDTH;
		else return 0;
	}
	
	public function getHeight() : Float {
		if (collisionLayer != null) return collisionLayer.getMap().levelHeight * collisionLayer.getMap().tileset.TILE_HEIGHT;
		else return 0;
	}
	
	public function getHeroesBelowPoint(px : Int, py : Int) : Array<Sprite> {
		var heroes = new Array();
		var count = collisionLayer.countHeroes();
		for (i in 1...count+1) {
			var hero = collisionLayer.getHero(count-i);
			if (hero.x < px && px < hero.x + hero.width && hero.y < py && py < hero.y + hero.height) {
				heroes.push(hero);
			}
		}
		ArraySort.sort(heroes, function(h1 : Sprite, h2 : Sprite) : Int { if (h1.z == h2.z) return 0; else if (h1.z < h2.z) return 1; else return -1; } );
		return heroes;
	}
	
	public function getSpritesBelowPoint(px : Int, py : Int) : Array<Sprite> {
		var sprites = new Array();
		for (i in 0...this.sprites.length) {
			var sprite = this.sprites[i];
			if (sprite.x + sprite.width < px)
				continue;
			if (sprite.x > px)
				break;
			var rect = sprite.collisionRect();
			if (rect.x < px && px < rect.x + rect.width && rect.y < py && py < rect.y + rect.height) {
				sprites.push(sprite);
			}
		}
		ArraySort.sort(sprites, function(h1 : Sprite, h2 : Sprite) : Int { if (h1.z == h2.z) return 0; else if (h1.z < h2.z) return 1; else return -1; } );
		return sprites;
	}
}