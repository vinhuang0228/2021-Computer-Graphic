#version 330

in vec2 texCoord;

out vec4 fragColor;

in vec3 vertex_normal;
in vec3 vertex_pos; 
in vec3 LightPos;
in vec3 vertex_color;

uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;

uniform int cur_light_mode;
uniform int shade_mode;

uniform vec3 light_pos;
uniform vec3 view_pos;

uniform vec3 intensity;
uniform int shininess;
uniform int angle;
uniform vec3 viewPos;

// [TODO] passing texture from main.cpp
// Hint: sampler2D
uniform sampler2D TextureMapping;

void main() {
	fragColor = vec4(texCoord.xy, 0, 1);

	// [TODO] sampleing from texture
	// Hint: texture
	// ambient
	vec3 ambient = vec3(0.15f, 0.15f, 0.15f) * ka;

	//diffuse
	vec3 norm = normalize(vertex_normal);
	if (cur_light_mode == 0){
		vec3 LightDir = normalize(- vec3(-1.0f,-1.0f, -1.0f));
	}else{
		vec3 LightDir = normalize(LightPos - vertex_pos);
	}
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

	vec3 result;
	if (cur_light_mode == 0)
		result = ambient + diffuse + specular;
	else if (cur_light_mode == 1)
		result = att_point * (ambient + diffuse + specular);
	else if (cur_light_mode == 2){

		 if (theta > cos( radians (angle ) )){ //cos(angle * PI / 180)
			result = spot_effect * (ambient + diffuse + specular);
		}
		else
			result = spot_effect * ambient;
	}

	if (shade_mode == 0) fragColor = vec4(vertex_color, 1.0f) * texture2D(TextureMapping,texCoord.xy);
	if (shade_mode == 1) fragColor = vec4(result, 1.0f) * texture2D(TextureMapping,texCoord.xy); 

	//fragColor = vec4(result, 1.0f) * texture2D(TextureMapping,texCoord.xy);

}
