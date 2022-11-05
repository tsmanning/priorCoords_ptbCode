function DrawTexturedQuad(width, height, outlineColor)
% Draws an OpenGL Textured quad.
%
% Draws a textured quad of the given size (width, height).
% If the outlineColor is supplied, the border of the quad is outlined.
% Color is an RGB triplet with range [0, 1]
%
% Transformations can be wrapped around this function:
%   glPushMatrix();
%   glRotatef(10, 0, 1, 0);
%   DrawTexturedQuad(10, 10, [1 0 0]);
%   glPopMatrix();
%
% Require OpenGL based PsychToolbox. Tested with version 3.0.8
%
% Bankslab, UC Berkeley
% cburns - 2007-06-21
% rheld - 2007-07-06

global GL

% Setup texture parameters
glTexEnvf(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.REPLACE);  % Changed by Robin from GL.REPLACE
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);

% Define our quad in screen dimensions, at the screen.
quadLeft    = -width/2;
quadRight   =  width/2;
quadTop     =  height/2;
quadBottom  = -height/2;

glEnable(GL.TEXTURE_2D);

% Draw a textured quad
glBegin(GL.QUADS);
% Draw rectangles in counter-clockwise order!
% lower-left
glTexCoord2f(0.0, 0.0);
glVertex2d(quadLeft, quadBottom);
% lower-right
glTexCoord2f(1.0, 0.0);
glVertex2d(quadRight, quadBottom);
% upper-right
glTexCoord2f(1.0, 1.0);
glVertex2d(quadRight,  quadTop);
% upper-left
glTexCoord2f(0.0, 1.0);
glVertex2d(quadLeft,  quadTop);
glEnd;

if nargin > 2
    % Outline the quad for visualization
    % Keep within the push/pop so it's rotated
    glDisable(GL.TEXTURE_2D);
    glColor3f(outlineColor(1), outlineColor(2), outlineColor(3));
    glBegin(GL.LINE_LOOP);
    glVertex2d(quadLeft, quadBottom);
    glVertex2d(quadRight, quadBottom);
    glVertex2d(quadRight,  quadTop);
    glVertex2d(quadLeft,  quadTop);
    glEnd;
end
