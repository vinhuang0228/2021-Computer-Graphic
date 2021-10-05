#version 330 core
# define PI 3.1415926535

out vec4 FragColor;
in vec3 vertex_color;
in vec3 vertex_normal;
in vec3 vertex_pos; 

uniform int cur_light_mode;
uniform int shade_mode;

uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;

uniform vec3 light_dir;
uniform vec3 light_pos; 

uniform vec3 intensity;
uniform int shininess;
uniform int angle;

//uniform vec3 viewPos;
//https://learnopengl-cn.readthedocs.io/zh/latest/02%20Lighting/02%20Basic%20Lighting/
void main() {
	// [TODO]
	FragColor = vec4(vertex_normal, 1.0f);

	// ambient
	vec3 ambient = vec3(0.15f,0.15f,0.15f) *ka;

	//diffuse
	vec3 norm = normalize(vertex_normal);
	vec3 lightDir = normalize(light_pos - vertex_pos);
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = intensity * diff * kd;

	//specular
	vec3 viewDir = normalize(light_dir-vertex_pos);
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(norm, halfwayDir), 0.0), shininess);
	vec3 specular = intensity * spec * ks;

	//attenuation
	float distance = length(light_pos - vertex_pos);
	float att_p = 1.0 / (0.01 + 0.8 * distance + 0.1 * distance * distance);
	att_p = min(att_p, 1);
	float att_s = min(1.0 / (0.05 + 0.3 * distance + 0.6 * distance * distance),1);

	float theta = dot(lightDir,normalize(-vec3(0,0,-1)));
	//float spot_effect = pow(max(dot(normalize(vertex_pos - light_pos), normalize(light_dir)), 0), 50);
	float spot_effect = pow(max(theta, 0), 50);

	vec3 result;

	if (cur_light_mode == 0)
		result = ambient + diffuse + specular;
	else if (cur_light_mode == 1)
		result = att_p * (ambient + diffuse + specular);
	else if (cur_light_mode == 2){
		 if (theta > cos( radians (angle ) )){ //cos(angle * PI / 180)
			
			result = spot_effect * (ambient + diffuse + specular);
		}
		else
			result = spot_effect * ambient * att_s;
	}


	if (shade_mode == 0) FragColor = vec4(vertex_color, 1.0f);
	if (shade_mode == 1) FragColor = vec4(result, 1.0f);
}
