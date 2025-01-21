final double ALL_PARTICLES_MASS = 1.0;
final double PERMITTIVITY = 0.5;
final double ALL_PARTICLES_RADIUS = 30.0;
final double UNIT_CHARGE = 50.0;


double w;
color positiveColor;
color negativeColor;
double outerForceStrength;

Grid grid;
ArrayList<Particle> particles;

boolean gridVisible;
boolean menuVisible;

void setup(){
  //size(500 , 500);
  fullScreen(P2D);
  frameRate(110);
  
  w = 40.0;
  positiveColor = color(163, 41, 41);
  negativeColor = color(41, 51, 163);
  
  grid = new Grid();
  particles = new ArrayList<Particle>();
  
  outerForceStrength = 1.0;
  
  gridVisible = true;
  menuVisible = false;
}

void draw(){
  background(0);
  
  if(gridVisible){
    grid.showGrid();
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
    
    
    particle.update();
    particle.show();
  }
  
  if(menuVisible){
    background(255);
    drawMenu();
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
  
  if(keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT){
    for(Particle particle : particles){
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
    "'g'",
    "'a'",
    "Arrow Keys",
    "Esc"    
  };
  
  String[] descriptionsTexts = {
    "Add Positive Charge",
    "Add Negative Charge",
    "Freeze / Unfreeze a particle",
    "Remove all particles",
    "Toggle Grid",
    "Toggle Arrows",
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
