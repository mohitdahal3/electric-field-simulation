final double ALL_PARTICLES_MASS = 1.0;
final double PERMITTIVITY = 0.5;
final double ALL_PARTICLES_RADIUS = 30.0;
final double UNIT_CHARGE = 50.0;


double w;
color positiveColor;
color negativeColor;
color longArrowColor;
color arrowColor;

double outerForceStrength;

float maxArrowLength;
float maxStrokeWeight;

Grid grid;
ArrayList<Particle> particles;

boolean gridVisible;
boolean arrowVisible;
boolean menuVisible;
boolean particlesVisible;

void setup(){
  //size(500 , 500);
  fullScreen(P2D);
  frameRate(110);
  
  w = 40.0;
  positiveColor = color(163, 41, 41);
  negativeColor = color(41, 51, 163);
  longArrowColor = color(255, 145, 0);
  arrowColor = color(104, 205, 31);
  
  maxArrowLength = ( (float) w * 3 ) / 4;
  maxStrokeWeight = 3;
  
  
  grid = new Grid();
  particles = new ArrayList<Particle>();
  
  outerForceStrength = 0.1;
  
  gridVisible = true;
  arrowVisible = true;
  menuVisible = false;
  particlesVisible = true;
}

void draw(){
  background(0);
  
  if(gridVisible){
    grid.showGrid();
  }
  
  if(arrowVisible){
    grid.calculateArrowValues();
    grid.drawArrows();
  }
  
  
  for(int i = 0; i < particles.size(); i++){
    for(int j = 0; j < particles.size(); j++){
      
      if(i!=j){  // For electric Attraction or repulsion
        particles.get(i).affect(particles.get(j));
      }
      
      if(j > i){  // For collision
        if(dist(particles.get(i).position , particles.get(j).position) < particles.get(i).radius + particles.get(j).radius){
          particles.get(i).collide(particles.get(j));
        }
      }
    }
  }
  
  for(Particle particle : particles){
    
    // For Edge Collision
    if(particle.position.x > width - particle.radius){
      particle.position.x = width - particle.radius;
      particle.velocity.x *= -1;
    }
    if(particle.position.x < particle.radius){
      particle.position.x = particle.radius;
      particle.velocity.x *= -1;
    }
    if(particle.position.y > height - particle.radius){
      particle.position.y = height - particle.radius;
      particle.velocity.y *= -1;
    }
    if(particle.position.y < particle.radius){
      particle.position.y = particle.radius;
      particle.velocity.y *= -1;
    }
    
    // For outer force
    if(keyPressed){
        if(particle.containsMouse()){
          particle.applyForce(
              (keyCode == UP)? new DVector(0.0 , -outerForceStrength)
            : (keyCode == DOWN)? new DVector(0.0 , outerForceStrength)
            : (keyCode == RIGHT)? new DVector(outerForceStrength , 0.0)
            : (keyCode == LEFT)? new DVector(-outerForceStrength , 0.0)
            : new DVector(0.0 , 0.0)
          );
        }
    }
    
    
    
    
    particle.update();
    
    if(particlesVisible){
      particle.show();
    }
    
  }
  
  
  if(menuVisible){
    background(255);
    drawMenu();
  }else{
    textSize(25);
    textAlign(LEFT , TOP);
    fill(255);
    text("Hold 'm' to see controls" , 5 , 5);   
  }
}

void keyPressed(){
  if(key == 'p'){
    particles.add(new Particle(mouseX , mouseY , UNIT_CHARGE));
  }
  if(key == 'n'){
    particles.add(new Particle(mouseX , mouseY , -UNIT_CHARGE));
  }
  if(key == 'x'){
    particles.clear();
  }
  if(key == 'g'){
    gridVisible = !gridVisible;
  }
  if(key == 'm'){
    menuVisible = true;
  }
  if(key == 'a'){
    arrowVisible = !arrowVisible;
  }
  if(key == 'd'){
    Particle particleToRemove = null;
    
    for(Particle particle : particles){
      if(particle.containsMouse()){
        particleToRemove = particle;
      }
    }
    
    if(particleToRemove != null){
      particles.remove(particleToRemove);
    }

  }
  if(key == 'h'){
    particlesVisible = !particlesVisible;
  }
    
}

void keyReleased(){
  if(key == 'm'){
    menuVisible = false;
  }
}

double dist(DVector a , DVector b){
  return Math.sqrt( ((b.x - a.x) * (b.x - a.x)) + ((b.y - a.y) * (b.y - a.y)) );
}

void mousePressed(){
  for(Particle particle : particles){
    if(particle.containsMouse()){
      particle.frozen = !particle.frozen;
    }
  }
}


void drawMenu(){
  String[] actionsTexts = {
    "'p'",
    "'n'",
    "Mouse Click",
    "'x'",
    "'d'",
    "'g'",
    "'a'",
    "'h'",
    "Arrow Keys",
    "Esc"    
  };
  
  String[] descriptionsTexts = {
    "Add Positive Charge",
    "Add Negative Charge",
    "Freeze / Unfreeze a particle",
    "Remove all particles",
    "Remove the Particle containing mouse",
    "Toggle Grid",
    "Toggle Arrows",
    "Toggle Particles",
    "Apply Force to particles",
    "Exit"
  };
  
  float headerTextSize = 50;
  float secondaryTextSize = 30;
  float textGap = 40;
  float headerTextGap = 90;
  float actionDescGap = 20;
  float headerYvalue = 300;
  float textXvalue = (width/2) - 100;
  
  textSize(headerTextSize);
  textAlign(CENTER , CENTER);
  fill(0);
  text("CONTROLS" , width/2 , headerYvalue);
  
  textSize(secondaryTextSize);
  for(int i = 0; i < actionsTexts.length; i++){
    textAlign(CENTER , CENTER);
    text("-" , textXvalue , headerYvalue + headerTextGap + (i * textGap));
    
    textAlign(RIGHT , CENTER);
    text(actionsTexts[i] , textXvalue - actionDescGap , headerYvalue + headerTextGap + (i * textGap));
    
    textAlign(LEFT , CENTER);
    text(descriptionsTexts[i] , textXvalue + actionDescGap , headerYvalue + headerTextGap + (i * textGap));
    
  } 
}

void drawArrow(DVector arrow , DVector base){
  arrow = arrow.copy();
  base = base.copy();
  
  double arrowLength = arrow.mag();
  if(arrowLength < 4){
    arrowLength = 4;
  }
  double extraLength = 0.0;
  
  
  if(arrowLength > maxArrowLength ){
    extraLength = arrowLength - maxArrowLength;
    arrowLength = maxArrowLength;
    arrow.setMag(arrowLength);
  }
  
  //arbritary decision based on some calcualtions
  extraLength = constrain((int)extraLength , 0 , 1920);
  float a = map((float)extraLength , 0 , 361 - maxArrowLength , 0 , 1);
  stroke(colorMap(color(115, 205, 31) , longArrowColor , a));
  
  float tipAngle = radians(20);
  float tipLength = (float)arrowLength / 4;
  PVector tipArrow = new PVector((float)arrow.x , (float)arrow.y); //special case
  tipArrow.setMag(-tipLength);
  
  
  float strokeWeightValue = map((float)arrowLength , 0 , maxArrowLength , 0 , maxStrokeWeight);
  if(strokeWeightValue < 0.3){
    strokeWeightValue = 0.3;
  }
  strokeWeight(strokeWeightValue);
  
  pushMatrix();
  
  translate((float)base.x , (float)base.y);
  line(0 , 0 , (float)arrow.x , (float)arrow.y);
  
  pushMatrix();
  translate((float)arrow.x , (float)arrow.y);
  line(0 , 0 , tipArrow.copy().rotate(tipAngle).x , tipArrow.copy().rotate(tipAngle).y);
  line(0 , 0 , tipArrow.copy().rotate(-tipAngle).x , tipArrow.copy().rotate(-tipAngle).y);
  popMatrix();
  
  popMatrix();
  
}



color colorMap(color c1, color c2, float a) {
    a = constrain(a, 0, 1);

    float r1 = red(c1);
    float g1 = green(c1);
    float b1 = blue(c1);
    
    float r2 = red(c2);
    float g2 = green(c2);
    float b2 = blue(c2);

    float r = lerp(r1, r2, a);
    float g = lerp(g1, g2, a);
    float b = lerp(b1, b2, a);

    return color(r, g, b);
}
