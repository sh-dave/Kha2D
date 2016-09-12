package kha2d;

// TODO (DK) remove None and use Null<Collision> or just null?
enum Collision {
	None;

	WorldBoundsLeft;
	WorldBoundsTop;
	WorldBoundsRight;
	WorldBoundsBottom;

	Tile(x: Int, y: Int);

	// (DK) WARNING:
	//	The array is cached internally to avoid unneccessary allocations, don't keep local references to it.
	//	If you need to keep the values, clone the array instead.
	Multiple(length: Int, collisions: Array<Collision>);
}
