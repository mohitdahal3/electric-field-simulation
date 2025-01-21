class DVector {
    double x, y, z;

    DVector() {
        this.x = 0.0;
        this.y = 0.0;
        this.z = 0.0;
    }

    DVector(double x, double y, double z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    DVector(double x, double y) {
        this.x = x;
        this.y = y;
        this.z = 0.0;
    }

    DVector(final DVector v) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
    }

    DVector add(final DVector other){
        this.x += other.x;
        this.y += other.y;
        this.z += other.z;
        
        return this;
    }

    DVector sub(final DVector other){
        this.x -= other.x;
        this.y -= other.y;
        this.z -= other.z;
        return this;
    }

    DVector mult(double scalar){
        this.x *= scalar;
        this.y *= scalar;
        this.z *= scalar;
        return this;
    }

    DVector div(double scalar){
        this.x /= scalar;
        this.y /= scalar;
        this.z /= scalar;
        return this;
    }

    DVector set(double x, double y, double z) {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    DVector set(final DVector v) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
        return this;
    }

    DVector normalize() {
        double magnitude = this.mag();
        if (magnitude != 0) {
            this.x /= magnitude;
            this.y /= magnitude;
            this.z /= magnitude;
        }
        return this;
    }

    DVector limit(double max) {
        if (this.magSq() > max * max) {
            this.setMag(max);
        }
        return this;
    }

    DVector setMag(double mag) {
        this.normalize();
        this.mult(mag);
        return this;
    }

    DVector rotate(double angle) {
        double cos = Math.cos(angle);
        double sin = Math.sin(angle);
        double newX = this.x * cos - this.y * sin;
        double newY = this.x * sin + this.y * cos;
        this.x = newX;
        this.y = newY;
        return this;
    }

    DVector copy() {
        return new DVector(this.x, this.y, this.z);
    }

    double mag() {
        return Math.sqrt((this.x * this.x) + (this.y * this.y) + (this.z * this.z));
    }

    double magSq() {
        return (this.x * this.x) + (this.y * this.y) + (this.z * this.z);
    }

    double heading() {
        return Math.atan2(this.y, this.x);
    }

    static DVector random2D() {
        double angle = Math.random() * 2 * Math.PI; 
        return new DVector(Math.cos(angle), Math.sin(angle));
    }

    static DVector random3D() {
        double theta = Math.random() * 2 * Math.PI;   
        double phi = Math.acos(2 * Math.random() - 1);
        double x = Math.sin(phi) * Math.cos(theta);
        double y = Math.sin(phi) * Math.sin(theta);
        double z = Math.cos(phi);
        return new DVector(x, y, z);
    }

    static DVector fromAngle(double angle) {
        return new DVector(Math.cos(angle), Math.sin(angle));
    }

    static DVector add(final DVector vector1, final DVector vector2) {
        return new DVector(
            vector1.x + vector2.x,
            vector1.y + vector2.y,
            vector1.z + vector2.z
        );
    }

    static DVector sub(final DVector vector1, final DVector vector2) {
        return new DVector(
            vector1.x - vector2.x,
            vector1.y - vector2.y,
            vector1.z - vector2.z
        );
    }
    
    static DVector mult(final DVector vector , double scalar){
      return new DVector(
        vector.x * scalar,
        vector.y * scalar,
        vector.z * scalar
      );
    }
    
    static DVector div(final DVector vector , double scalar){
      return new DVector(
        vector.x / scalar,
        vector.y / scalar,
        vector.z / scalar
      );
    }

    static double angleBetween(final DVector v1, final DVector v2) {
        double dot = (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z);
        double mag1 = v1.mag();
        double mag2 = v2.mag();
        if (mag1 == 0 || mag2 == 0) {
            return 0.0; 
        }
        double cosine = dot / (mag1 * mag2);
        return Math.acos(Math.max(-1.0, Math.min(1.0, cosine)));
    }

}
