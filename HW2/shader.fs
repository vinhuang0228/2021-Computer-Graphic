// shader.fs

#version 330 core
# define PI 3.1415926535

out vec4 FragColor;
in vec3 vertex_color;
in vec3 vertex_normal;
in vec3 vertex_pos; //viewspace

uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;
uniform vec3 light_dir;
uniform vec3 lightPos; //viewspace
uniform vec3 viewPos;
uniform vec3 intensity;
uniform int cur_light_mode;
uniform int shininess;
uniform int angle;
uniform int shade_mode;

void main() {
	// [TODO]
	 FragColor = vec4(vertex_normal, 1.0f);

//==================ambient==================
	
	vec3 ambientStrength = vec3(0.15f, 0.15f, 0.15f);
	vec3 La = ambientStrength;
	//float ambientStrength = 0.1f;
    //vec3 ambient = ambientStrength * lightColor;
    //vec3 result = ambient * objectColor;
	
//==================diffuse==================
	vec3 Ld = intensity;
	vec3 norm = normalize(vertex_normal);
	vec3 lightDir = normalize(lightPos - vertex_pos);
	float diff = max(dot(norm, lightDir), 0.0);
	//vec3 norm = normalize(Normal);
	//vec3 lightDir = normalize(lightPos - FragPos);
	//float diff = max(dot(norm, lightDir), 0.0);
	//vec3 diffuse = diff * lightColor;

//==================specular==================
	vec3 Ls = intensity;
	
	//halfway vector Blinn-Phong
	vec3 viewDir = normalize(viewPos-vertex_pos);
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(norm, halfwayDir), 0.0), shininess);

//==================attenuation==================
	float att_d;
	float att_s;
	if (cur_light_mode == 1){
		float distance = length(lightPos - vertex_pos);
		att_d = 1.0 / (0.01 + 0.8 * distance + 0.1 * distance * distance);
	}
	else if (cur_light_mode == 2){
		float distance = length(lightPos - vertex_pos);
		att_s = 1.0 / (0.05 + 0.3 * distance + 0.6 * distance * distance);
	}

//==================compute result==================
	vec3 result;
	//directional
	if (cur_light_mode == 0){
		result = La * ka + Ld * kd * diff  + Ls * ks * spec;
	}
	//point
	else if (cur_light_mode == 1){
		result = att_d * (La * ka + Ld * kd * diff +  Ls * ks * spec);
	}
	//spot
	else if (cur_light_mode == 2){
		float cosine = dot(vertex_pos - lightPos, light_dir) / (length(vertex_pos - lightPos) * length(light_dir));
		if (cosine <= cos(angle * PI / 180)){
			result = La * ka;
		}
		else if (cosine > cos(angle * PI / 180)){
			float spot_effect = pow(max(dot(normalize(vertex_pos - lightPos), normalize(light_dir)), 0), 50);
			result = att_s * spot_effect * (La * ka + Ld * kd * diff + Ls * ks * spec);
		}
	}
	if (shade_mode == 0) FragColor = vec4(vertex_color, 1.0f);
	if (shade_mode == 1) FragColor = vec4(result, 1.0f);


}
