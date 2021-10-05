#version 330

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;
layout (location = 3) in vec2 aTexCoord;

out vec2 texCoord;
out vec3 vertex_normal;
out vec3 vertex_pos;
out vec3 LightPos;
out vec3 vertex_color;

uniform mat4 um4p;	
uniform mat4 um4v;
uniform mat4 um4m;

uniform int cur_light_mode;
uniform int shade_mode;

uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;

uniform vec3 light_pos;
uniform vec3 view_pos;

uniform vec3 intensity;
uniform int shininess;
uniform int angle;
uniform vec3 viewPos;

// ---for attenuation---
vec3 result;
float constant;
float linear;
float quadratic;
float distance;
float attenuation;
float theta;

// [TODO] passing uniform variable for texture coordinate offset

void main() 
{
	// [TODO]

	gl_Position = um4p * um4v * um4m * vec4(aPos, 1.0);
	vertex_color = aColor;

	//vertex_pos = vec3(pos.x, pos.y, pos.z);
	vec4 pos = (um4v * um4m) * vec4(aPos.x, aPos.y, aPos.z, 1.0);	
	//vertex_pos = vec3(pos.x, pos.y, pos.z); // = FragPos
	

	//vec4 normal = transpose(inverse(um4v * um4m)) * vec4(aNormal.x, aNormal.y, aNormal.z, 0.0f); 
	//vertex_normal = vec3(normal.x, normal.y, normal.z); //=Normal
	
	vertex_pos = vec3(um4v * um4m * vec4(aPos, 1.0)); // = FragPos
	vertex_normal = mat3(transpose(inverse(um4v * um4m))) * aNormal;
	LightPos = vec3(um4v * vec4(light_pos, 1.0));

	// ambient
	vec3 ambient = vec3(0.15f, 0.15f, 0.15f) * ka;

	//diffuse
	vec3 norm = normalize(vertex_normal);
	vec3 LightDir = normalize(LightPos - vertex_pos);
	float diff = max(dot(norm, LightDir), 0.0);
	vec3 diffuse = intensity * kd * diff;

	//specular
	vec3 viewDir = normalize(view_pos - vertex_pos);
	vec3 halfwayDir = normalize(LightDir + viewDir);
	float spec = pow(max(dot(norm, halfwayDir), 0.0), shininess);
	vec3 specular = intensity * ks * spec;

	//attenuation
	float distance = length(LightPos - vertex_pos);
	float att_point = 1.0f / (0.01 + 0.8 * distance + 0.1 * distance * distance);
	att_point = min(att_point, 1);

	float att_spot = 1.0f / (0.05 + 0.3 * distance + 0.6 * distance * distance);
	float theta = dot(LightDir,normalize(-vec3(0,0,-1)));
	float spot_effect = pow(max(theta, 0), 50);


	//attenuation
	constant=0.05;
    linear=0.3;
    quadratic=0.6;
    distance = length(LightPos -vertex_pos );
    theta = dot(LightDir, normalize(-vec3(0,0,-1))); 
    float spoteffect = pow(max(theta, 0), 50);

	


	if (cur_light_mode == 0)
		vertex_color = ambient + diffuse + specular;
	else if (cur_light_mode == 1)
		vertex_color = att_point * (ambient + diffuse + specular);
	else if (cur_light_mode == 2){
		if(theta > cos( radians (angle ) )){
                 attenuation = min(1.0f / (constant + linear*distance +quadratic*(distance*distance)),1); 
                 vertex_color = spoteffect*attenuation*(ambient + diffuse + specular) ;

            }else{
                 vertex_color = spoteffect*  ambient ;
            }
		/*
		 if (theta > cos( radians (angle ) )){ //cos(angle * PI / 180)
			vertex_color = spot_effect * att_spot * (ambient + diffuse + specular);
		}
		else
			vertex_color = spot_effect * ambient;
		*/
	}


}
