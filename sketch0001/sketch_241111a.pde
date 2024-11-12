import processing.sound.*;

float spacing = 1;
float speed = 0;
float offset = 0;
float feedbackGain = 1.2;
float threshold = 0.15;
PGraphics pg;
AudioIn mic;
Amplitude amp;
float rotationAngle = 0; 

void setup() {
  surface.setResizable(false);
  surface.setAlwaysOnTop(true);
  fullScreen();
  pg = createGraphics(width, height);
  background(0);

  // Initialiser le microphone et l'analyseur d'amplitude
  mic = new AudioIn(this, 0);
  mic.start();
  amp = new Amplitude(this);
  amp.input(mic);
}

void draw() {
  background(0);
  image(pg, 0, 0);

  tint(255, 255 * feedbackGain);
  
  blendMode(ADD);

  pg.beginDraw();
  pg.image(pg, 0, 0);
  pg.endDraw();

  // Analyse du niveau sonore du microphone
  float micLevel = amp.analyze() * 200;

  // Appliquer le seuil de volume
  if (micLevel >= threshold) {
    spacing = map(micLevel, threshold, 1, 15, 500);
    rotationAngle = map(micLevel, threshold, 1, 0, PI / 8); 
  } else {
    spacing = 300; 
    rotationAngle = 0; 
  }

  offset += speed;

  pg.beginDraw();
  pg.background(0, 20);

  // Appliquer la rotation et dessiner les lignes plus grandes que l'écran
  pg.pushMatrix();
  pg.translate(width / 2, height / 2); // Déplacer l'origine au centre
  pg.rotate(rotationAngle); // Appliquer la rotation
  pg.translate(-width / 2, -height / 2); // Revenir à l'origine en haut à gauche

  for (float i = -offset; i < width; i += spacing * 2) {
    drawHorizontalGradient(i, -height / 2, spacing, height * 2, true, pg);
    drawHorizontalGradient(i + spacing, -height / 2, spacing, height * 2, false, pg);
  }

  pg.popMatrix();
  pg.endDraw();

  image(pg, 0, 0);

  blendMode(BLEND);
}

void drawHorizontalGradient(float x, float y, float w, float h, boolean blackToWhite, PGraphics pg) {
  for (int i = 0; i < w; i++) {
    float alpha;
    if (i < w * 0.15) {
      alpha = map(i, 0, w * 0.45, 0, 255);
    } else if (i > w * 0.85) {
      alpha = map(i, w * 0.55, w, 255, 0);
    } else {
      alpha = 0;
    }
    
    if (!blackToWhite) alpha = 255 - alpha;
    pg.fill(255, alpha);
    pg.noStroke();
    float squareSize = h / 2.0; 

    for (int j = 0; j < h; j += squareSize) {
      pg.rect(x + i, y + j, 1, squareSize); 
    }
  }
}

void stop() {
  mic.stop();
  super.stop();
}
