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

    void add(final DVector other){
        this.x += other.x;
        this.y += other.y;
        this.z += other.z;
    }

    void sub(final DVector other){
        this.x -= other.x;
        this.y -= other.y;
        this.z -= other.z;
    }

    void mult(double scalar){
        this.x *= scalar;
        this.y *= scalar;
        this.z *= scalar;
    }

    void div(double scalar){
        this.x /= scalar;
        this.y /= scalar;
        this.z /= scalar;
    }

    void set(double x, double y, double z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    void set(final DVector v) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
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

    DVector copy() {
        return new DVector(this.x, this.y, this.z);
    }

    double mag() {
        return Math.sqrt((this.x * this.x) + (this.y * this.y) + (this.z * this.z));
    }

    double magSq() {
        return (this.x * this.x) + (this.y * this.y) + (this.z * this.z);
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

    void normalize() {
        double magnitude = this.mag();
        if (magnitude != 0) {
            this.x /= magnitude;
            this.y /= magnitude;
            this.z /= magnitude;
        }
    }

    void limit(double max) {
        if (this.magSq() > max * max) {
            this.setMag(max);
        }
    }

    void setMag(double mag) {
        this.normalize();
        this.mult(mag);
    }

    double heading() {
        return Math.atan2(this.y, this.x);
    }

    void rotate(double angle) {
        double cos = Math.cos(angle);
        double sin = Math.sin(angle);
        double newX = this.x * cos - this.y * sin;
        double newY = this.x * sin + this.y * cos;
        this.x = newX;
        this.y = newY;
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






class Grid{
  DVector[][] intersections;
  DVector[][] arrowValues;
  
  int numVerticalLines;
  int numHorizontalLines;
  
  Grid(){
    this.numVerticalLines = floor(width/w) + 1;
    this.numHorizontalLines = floor(height/w) + 1;
    
    this.intersections = new DVector[this.numVerticalLines][numHorizontalLines];
    this.arrowValues = new DVector[this.numVerticalLines][numHorizontalLines];

    for(int i = 0; i < this.numVerticalLines; i++){
      for(int j = 0; j < this.numHorizontalLines; j++){
        this.intersections[i][j] = new DVector(i*w , j*w);
      }
    }

  }
  
  void showGrid(){
    strokeWeight(1);
    stroke(255 , 70);
    
    for(int i = 0; i < this.numVerticalLines; i++){
      line(i * w , 0 , i * w , height);
    }
    
    for(int j = 0; j < this.numVerticalLines; j++){
      line(0 , j * w , width , j * w);
    }
  }
}



class Particle{
  DVector position;
  DVector velocity;
  DVector acceleration;
  DVector force;
  
  double mass;
  double radius;
  double charge;
  
  boolean frozen;
  
  Particle(double x , double y , double charge){
    this.position = new DVector(x, y);
    this.velocity = new DVector(0,0);
    this.acceleration = new DVector(0,0);
    this.force = new DVector(0,0);
    
    this.mass = ALL_PARTICLES_MASS;
    this.radius = ALL_PARTICLES_RADIUS;
    this.charge = charge;
    
    this.frozen = false;
  }
  
  void show(){
     noStroke();
     fill( (this.charge > 0)? positiveColor : negativeColor );
     circle(this.position.x , this.position.y , this.radius * 2);
     
     if(this.frozen){
       stroke(0);
       strokeWeight(5);
       point(this.position.x , this.position.y);
     }
  }
  
  void update(){
    if(!this.frozen){
      this.acceleration = DVector.mult(this.force.copy() , 1/this.mass);
      
      this.velocity.add(this.acceleration);
      this.position.add(this.velocity);
      
      this.force.mult(0);
    }else{
      this.velocity.mult(0);
      this.force.mult(0);
    }
  }
  
  void applyForce(DVector f){
    this.force.add(f.copy());
  }
  
  void affect(Particle other){
    double r = dist(this.position.x, this.position.y , other.position.x , other.position.y);
    if(r < this.radius + other.radius){
      r = this.radius + other.radius;
    }
    double electricForceMagnitude = (this.charge * other.charge) / (4 * PI * PERMITTIVITY * pow(r+100 , 2));
    DVector electricForce = DVector.sub(other.position , this.position);
    electricForce.setMag(electricForceMagnitude);
    other.applyForce(electricForce);
  }
  
  void collide(Particle other){
    if(this.frozen==false && other.frozen==false){
      DVector centerDisplacementA = DVector.sub(other.position.copy() , this.position.copy());
      DVector centerDisplacementB = DVector.sub(this.position.copy() , other.position.copy());
    
      double angleA = DVector.angleBetween(this.velocity , centerDisplacementA);
      double angleB = DVector.angleBetween(other.velocity , centerDisplacementB);
    
      double va1 , va2 , vb1 , vb2;
    
      va1 = this.velocity.mag() * cos(angleA);
      vb1 = other.velocity.mag() * cos(angleB) * -1;
    
      DVector effectiveVelocityA = centerDisplacementA.copy().setMag(va1);
      DVector perpVelocityA = DVector.sub(this.velocity , effectiveVelocityA);
  
      DVector effectiveVelocityB = centerDisplacementB.copy().setMag(-vb1);
      DVector perpVelocityB = DVector.sub(other.velocity , effectiveVelocityB);

    
      va2 = ( ((this.mass - other.mass)/(this.mass + other.mass)) * (va1)) + ( ((2 * other.mass)/(this.mass + other.mass)) *(vb1) ); 
      vb2 = ( ((other.mass - this.mass)/(this.mass + other.mass)) * (vb1)) + ( ((2 * this.mass)/(this.mass + other.mass))*(va1) );
    
      effectiveVelocityA.setMag(va2);
      effectiveVelocityB.setMag(-vb2);
    
      this.velocity = DVector.add(effectiveVelocityA , perpVelocityA);
      other.velocity = DVector.add(effectiveVelocityB , perpVelocityB);
    
      if(centerDisplacementA.mag() < this.radius + other.radius){
        double overlap = this.radius + other.radius - centerDisplacementA.mag();
        this.position.add(centerDisplacementA.copy().setMag(overlap/-2));
        other.position.add(centerDisplacementB.copy().setMag(overlap/-2));
      }
      
    }else if(this.frozen && other.frozen==false){
      DVector centerDisplacementB = DVector.sub(this.position.copy() , other.position.copy());
      double angleB = DVector.angleBetween(other.velocity , centerDisplacementB);
      
      DVector effectiveVelocityB = centerDisplacementB.copy().setMag(other.velocity.copy().mag() * cos(angleB));
      DVector perpVelocityB = DVector.sub(other.velocity , effectiveVelocityB);
            
      other.velocity = DVector.add(effectiveVelocityB.mult(-1) , perpVelocityB);
      
      if(centerDisplacementB.mag() < this.radius + other.radius){
        double overlap = this.radius + other.radius - centerDisplacementB.mag();
        other.position.add(centerDisplacementB.copy().setMag(-overlap));
      }
      
    }else if(this.frozen==false && other.frozen){
      DVector centerDisplacementA = DVector.sub(other.position.copy() , this.position.copy());
      double angleA = DVector.angleBetween(this.velocity , centerDisplacementA);
      
      DVector effectiveVelocityA = centerDisplacementA.copy().setMag(this.velocity.copy().mag() * cos(angleA));
      DVector perpVelocityA = DVector.sub(this.velocity , effectiveVelocityA);
            
      this.velocity = DVector.add(effectiveVelocityA.mult(-1) , perpVelocityA);
      
      if(centerDisplacementA.mag() < this.radius + other.radius){
        double overlap = this.radius + other.radius - centerDisplacementA.mag();
        this.position.add(centerDisplacementA.copy().setMag(-overlap));
      }
      
    }
  }

  
  boolean containsMouse(){
    return (dist(this.position.x , this.position.y , mouseX , mouseY) < this.radius);
  }
  
}
