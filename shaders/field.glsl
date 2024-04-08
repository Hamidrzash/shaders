
precision highp float;
uniform float iTime;
uniform vec2 iResolution;

out vec4 fragColor;

const int iterationTime1 = 20;
const float scale = 6.;
const int iterationTime2 = 1;

const float velocity_x = 0.1;
const float velocity_y = 0.2;

const float mode_2_speed = 2.5;
const float mode_1_detail = 200.;
const float mode_1_twist = 50.;

float f(in vec2 p)
{
    return sin(p.x+sin(p.y+iTime*velocity_x)) * sin(p.y*p.x*0.1+iTime*velocity_y);
}



vec2 vel;
vec2 pos;


//---------------Field to visualize defined here-----------------

void field(in vec2 p,in int mode)
{
    vec2 ep = vec2(0.05,0.);
    vec2 rz= vec2(0);
    //# centered grid sampling
    for( int i=0; i<iterationTime1; i++ )
    {
        float t0 = f(p);
        float t1 = f(p + ep.xy);
        float t2 = f(p + ep.yx);
        vec2 g = vec2((t1-t0), (t2-t0))/ep.xx;
        vec2 t = vec2(-g.y,g.x);

        //# need update 'p' for next iteration,but give it some change.
        p += (mode_1_twist*0.01)*t + g*(1./mode_1_detail);
        p.x = p.x + sin( iTime*mode_2_speed/10.)/10.;
        p.y = p.y + cos(iTime*mode_2_speed/10.)/10.;
        rz= g;
    }

    vel = rz;
    // add curved effect into curved mesh
    for(int i=1; i<iterationTime2; i++){
        //# try comment these 2 lines,will give more edge effect
        p.x+=0.3/float(i)*sin(float(i)*3.*p.y+iTime*mode_2_speed) + 0.5;
        p.y+=0.3/float(i)*cos(float(i)*3.*p.x + iTime*mode_2_speed) + 0.5;
    }
    pos = p;
}
//---------------------------------------------------------------



vec3 getRGB(in int mode){
    vec2 p = pos;
    float r=cos(p.x+p.y+1.)*.5+.5;
    float g=sin(p.x+p.y+1.)*.5+.5;
    float b=(sin(p.x+p.y)+cos(p.x+p.y))*.3+.5;
    vec3 col = sin(vec3(-.3,0.1,0.5)+p.x-p.y)*0.65+0.35;
    return vec3(r,g,b);

}

void mainImage(in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy-0.5 ;
    p.x *= iResolution.x/iResolution.y;
    p *= scale;

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col;
    float fviz;

    int vector_mode = 1;


    //vec2 fld = field(p,vector_mode).vel;
    //col = sin(vec3(-.3,0.1,0.5)+fld.x-fld.y)*0.65+0.35;
    field(p,vector_mode);
    col = getRGB(vector_mode) * 0.85;



    fragColor = vec4(col,1.0);
}

void main() {
    vec2 pos = gl_FragCoord.xy;
    mainImage(pos);
}