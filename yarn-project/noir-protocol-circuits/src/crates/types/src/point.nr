// TODO: change this to be called Grumpkin Point
struct Point {
    x: Field,
    y: Field,
}

impl Point {
    pub fn ZERO() -> Self {
        Point {
            x: 0,
            y: 0,
        }
    }

    // TODO(David): Would be quite careful here as (0,0) is not a point
    // on the curve. A boolean flag may be the better approach here,
    // would also cost less constraints. It seems like we don't need to 
    // group arithmetic either. 
    fn assert_is_zero(self) {
        assert(self.x == 0);
        assert(self.y == 0);
    }
}
