final float ALL_PARTICLES_MASS = 1;
final float PERMITTIVITY = 0.5;
final float ALL_PARTICLES_RADIUS = 30;
final float UNIT_CHARGE = 50;


float w;
color positiveColor;
color negativeColor;

Grid grid;
ArrayList<Particle> particles;

void setup(){
  fullScreen(P2D);
  frameRate(110);
  
  w = 40;
  positiveColor = color(163, 41, 41);
  negativeColor = color(41, 51, 163);
  
  grid = new Grid();
  particles = new ArrayList<Particle>();
}

void draw(){
  background(0);
  grid.showGrid();
  
  
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
}

float dist(PVector a , PVector b){
  return dist(a.x , a.y , b.x , b.y);
}

void mousePressed(){
  for(Particle particle : particles){
    if(particle.containsMouse()){
      particle.frozen = !particle.frozen;
    }
  }
}
