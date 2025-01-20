class Grid{
  PVector[][] intersections;
  PVector[][] arrowValues;
  
  int numVerticalLines;
  int numHorizontalLines;
  
  Grid(){
    this.numVerticalLines = floor(width/w) + 1;
    this.numHorizontalLines = floor(height/w) + 1;
    
    this.intersections = new PVector[this.numVerticalLines][numHorizontalLines];
    this.arrowValues = new PVector[this.numVerticalLines][numHorizontalLines];

    for(int i = 0; i < this.numVerticalLines; i++){
      for(int j = 0; j < this.numHorizontalLines; j++){
        this.intersections[i][j] = new PVector(i*w , j*w);
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
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector force;
  
  float mass;
  float radius;
  float charge;
  
  boolean frozen;
  
  Particle(float x , float y , float charge){
    this.position = new PVector(x, y);
    this.velocity = new PVector(0,0);
    this.acceleration = new PVector(0,0);
    this.force = new PVector(0,0);
    
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
      this.acceleration = PVector.mult(this.force.copy() , 1/this.mass);
      
      this.velocity.add(this.acceleration);
      this.position.add(this.velocity);
      
      this.force.mult(0);
    }else{
      this.velocity.mult(0);
      this.force.mult(0);
    }
  }
  
  void applyForce(PVector f){
    this.force.add(f.copy());
  }
  
  void affect(Particle other){
    float r = dist(this.position.x, this.position.y , other.position.x , other.position.y);
    if(r < this.radius + other.radius){
      r = this.radius + other.radius;
    }
    float electricForceMagnitude = (this.charge * other.charge) / (4 * PI * PERMITTIVITY * pow(r+100 , 2));
    PVector electricForce = PVector.sub(other.position , this.position);
    electricForce.setMag(electricForceMagnitude);
    other.applyForce(electricForce);
  }
  
  void collide(Particle other){
    if(this.frozen==false && other.frozen==false){
      PVector centerDisplacementA = PVector.sub(other.position.copy() , this.position.copy());
      PVector centerDisplacementB = PVector.sub(this.position.copy() , other.position.copy());
    
      float angleA = PVector.angleBetween(this.velocity , centerDisplacementA);
      float angleB = PVector.angleBetween(other.velocity , centerDisplacementB);
    
      float va1 , va2 , vb1 , vb2;
    
      va1 = this.velocity.mag() * cos(angleA);
      vb1 = other.velocity.mag() * cos(angleB) * -1;
    
      PVector effectiveVelocityA = centerDisplacementA.copy().setMag(va1);
      PVector perpVelocityA = PVector.sub(this.velocity , effectiveVelocityA);
  
      PVector effectiveVelocityB = centerDisplacementB.copy().setMag(-vb1);
      PVector perpVelocityB = PVector.sub(other.velocity , effectiveVelocityB);

    
      va2 = ( ((this.mass - other.mass)/(this.mass + other.mass)) * (va1)) + ( ((2 * other.mass)/(this.mass + other.mass)) *(vb1) ); 
      vb2 = ( ((other.mass - this.mass)/(this.mass + other.mass)) * (vb1)) + ( ((2 * this.mass)/(this.mass + other.mass))*(va1) );
    
      effectiveVelocityA.setMag(va2);
      effectiveVelocityB.setMag(-vb2);
    
      this.velocity = PVector.add(effectiveVelocityA , perpVelocityA);
      other.velocity = PVector.add(effectiveVelocityB , perpVelocityB);
    
      if(centerDisplacementA.mag() < this.radius + other.radius){
        float overlap = this.radius + other.radius - centerDisplacementA.mag();
        this.position.add(centerDisplacementA.copy().setMag(overlap/-2));
        other.position.add(centerDisplacementB.copy().setMag(overlap/-2));
      }
      
    }else if(this.frozen && other.frozen==false){
      PVector centerDisplacementB = PVector.sub(this.position.copy() , other.position.copy());
      float angleB = PVector.angleBetween(other.velocity , centerDisplacementB);
      
      PVector effectiveVelocityB = centerDisplacementB.copy().setMag(other.velocity.copy().mag() * cos(angleB));
      PVector perpVelocityB = PVector.sub(other.velocity , effectiveVelocityB);
            
      other.velocity = PVector.add(effectiveVelocityB.mult(-1) , perpVelocityB);
      
      if(centerDisplacementB.mag() < this.radius + other.radius){
        float overlap = this.radius + other.radius - centerDisplacementB.mag();
        other.position.add(centerDisplacementB.copy().setMag(-overlap));
      }
      
    }else if(this.frozen==false && other.frozen){
      PVector centerDisplacementA = PVector.sub(other.position.copy() , this.position.copy());
      float angleA = PVector.angleBetween(this.velocity , centerDisplacementA);
      
      PVector effectiveVelocityA = centerDisplacementA.copy().setMag(this.velocity.copy().mag() * cos(angleA));
      PVector perpVelocityA = PVector.sub(this.velocity , effectiveVelocityA);
            
      this.velocity = PVector.add(effectiveVelocityA.mult(-1) , perpVelocityA);
      
      if(centerDisplacementA.mag() < this.radius + other.radius){
        float overlap = this.radius + other.radius - centerDisplacementA.mag();
        this.position.add(centerDisplacementA.copy().setMag(-overlap));
      }
      
    }
  }

  
  boolean containsMouse(){
    return (dist(this.position.x , this.position.y , mouseX , mouseY) < this.radius);
  }
  
}
