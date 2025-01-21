class Grid{
  DVector[][] intersections;
  DVector[][] arrowValues;
  
  int numVerticalLines;
  int numHorizontalLines;
  
  Grid(){
    this.numVerticalLines = (int) Math.floor(width/w) + 1;
    this.numHorizontalLines = (int) Math.floor(height/w) + 1;
    
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
      line( (float) (i * w) , 0 , (float) (i * w) , height);
    }
    
    for(int j = 0; j < this.numVerticalLines; j++){
      line(0 , (float)(j * w) , width , (float)(j * w));
    }
  }
  
  void calculateArrowValues(){
    for(int i = 0; i < this.numVerticalLines; i++){
      for(int j = 0; j < this.numHorizontalLines; j++){
        
        this.arrowValues[i][j] = new DVector();
        DVector result = new DVector();
        
        for(Particle particle : particles){
          double r = dist(particle.position , this.intersections[i][j]);
          if(r < particle.radius){
            r = particle.radius;
          }
          double magnitude = (particle.charge * 10000) / (4 * PI * PERMITTIVITY * Math.pow(r , 1.6));
          DVector direction = DVector.sub(this.intersections[i][j] , particle.position);
          direction.setMag(magnitude);
          result.add(direction);
        }
        
        this.arrowValues[i][j] = result.copy();
        
      }
    }
  }
  
  void drawArrows(){
    for(int i = 0; i < this.numVerticalLines; i++){
      for(int j = 0; j < this.numHorizontalLines; j++){
        drawArrow(this.arrowValues[i][j].copy() , this.intersections[i][j].copy());
      }
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
     circle((float)this.position.x , (float)this.position.y , (float)this.radius * 2);
     
     if(this.frozen){
       stroke(0);
       strokeWeight(5);
       point((float)this.position.x , (float)this.position.y);
     }
  }
  
  void update(){
    if(!this.frozen){
      this.acceleration = DVector.div(this.force.copy() , this.mass);
      
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
    double r = dist(this.position , other.position);
    if(r < this.radius + other.radius){
      r = this.radius + other.radius;
    }
    double electricForceMagnitude = (this.charge * other.charge) / (4 * PI * PERMITTIVITY * (r+100) * (r+100));
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
    
      va1 = this.velocity.mag() * Math.cos(angleA);
      vb1 = other.velocity.mag() * Math.cos(angleB) * -1;
    
      DVector effectiveVelocityA = centerDisplacementA.copy();
      effectiveVelocityA.setMag(va1);
      
      DVector perpVelocityA = DVector.sub(this.velocity , effectiveVelocityA);
  
      DVector effectiveVelocityB = centerDisplacementB.copy();
      effectiveVelocityB.setMag(-vb1);
      
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
      
      DVector effectiveVelocityB = centerDisplacementB.copy().setMag(other.velocity.copy().mag() * Math.cos(angleB));
      DVector perpVelocityB = DVector.sub(other.velocity , effectiveVelocityB);
            
      other.velocity = DVector.add(effectiveVelocityB.mult(-1) , perpVelocityB);
      
      if(centerDisplacementB.mag() < this.radius + other.radius){
        double overlap = this.radius + other.radius - centerDisplacementB.mag();
        other.position.add(centerDisplacementB.copy().setMag(-overlap));
      }
      
    }else if(this.frozen==false && other.frozen){
      DVector centerDisplacementA = DVector.sub(other.position.copy() , this.position.copy());
      double angleA = DVector.angleBetween(this.velocity , centerDisplacementA);
      
      DVector effectiveVelocityA = centerDisplacementA.copy().setMag(this.velocity.copy().mag() * Math.cos(angleA));
      DVector perpVelocityA = DVector.sub(this.velocity , effectiveVelocityA);
            
      this.velocity = DVector.add(effectiveVelocityA.mult(-1) , perpVelocityA);
      
      if(centerDisplacementA.mag() < this.radius + other.radius){
        double overlap = this.radius + other.radius - centerDisplacementA.mag();
        this.position.add(centerDisplacementA.copy().setMag(-overlap));
      }
      
    }
  }

  
  boolean containsMouse(){
    return (dist(this.position , new DVector(mouseX , mouseY)) < this.radius);
  }
  
}
