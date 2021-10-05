// shader.vs

#version 330 core
# define PI 3.1415926535

layout (location = 0) in vec3 a_Pos;
layout (location = 1) in vec3 a_Color;
//layout(location = 1) in vec2 textCoord;
layout (location = 2) in vec3 a_Normal;

out vec3 vertex_color;
out vec3 vertex_normal;
out vec3 vertex_pos;

uniform mat4 mvp;
uniform mat4 mv;
uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;
uniform vec3 light_dir;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform vec3 intensity;
uniform int cur_light_mode;
uniform int shininess;
uniform int angle;
uniform int shade_mode;

// https://learnopengl-cn.readthedocs.io/zh/latest/02%20Lighting/02%20Basic%20Lighting/
void main()
{
	// [TODO]
	//FragColor = vec4(vertex_normal, 1.0f);
	//gl_Position = projection * view * model * vec4(position, 1.0f);
	gl_Position = mvp * vec4(a_Pos.x, a_Pos.y, a_Pos.z, 1.0f);

	//==================phong_model==================
	//FragPos = vec3(model * vec4(position, 1.0));
	//mat3 normalMatrix = mat3(transpose(inverse(model)));
	//FragNormal = normalMatrix * normal;
	vec4 pos = mv * vec4(a_Pos.x, a_Pos.y, a_Pos.z, 1.0f);
	vec4 normal = transpose(inverse(mv)) * vec4(a_Normal.x, a_Normal.y, a_Normal.z, 0.0f);


	vertex_pos = vec3(pos.x, pos.y, pos.z);
	vertex_normal = vec3(normal.x, normal.y, normal.z);
	
	//==================ambient==================
	vec3 ambientStrength = vec3(0.15f, 0.15f, 0.15f);
	vec3 La = ambientStrength;
	
	//==================diffuse==================

	vec3 Ld = intensity;
	vec3 norm = normalize(vertex_normal);

	vec3 lightDir = normalize(lightPos - vertex_pos);
	float diff = max(dot(norm, lightDir), 0.0);

	//vec3 norm = normalize(Normal);
	//vec3 lightDir = normalize(lightPos - FragPos);
	//float diff = max(dot(norm, lightDir), 0.0);

	//==================specular==================
	vec3 Ls = intensity;

	//halfway vector Blinn-Phong
	vec3 viewDir = normalize(viewPos-vertex_pos);
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(norm, halfwayDir), 0.0), shininess);

	//==================attenuation==================
	//p23
	float att_d;
	float att_s;
	float distance = length(lightPos - vertex_pos);
	//point
	if (cur_light_mode == 1){
		att_d = 1.0 / (0.01 + 0.8 * distance + 0.1 * distance * distance);
	}
	//spot
	else if (cur_light_mode == 2){
		att_s = 1.0 / (0.05 + 0.3 * distance + 0.6 * distance * distance);
	}

	//==================result==================
	vec3 result;
	//directional
	/*
	vec3 ambient  = light.ambient  * vec3(texture(material.diffuse, TexCoords));
    vec3 diffuse  = light.diffuse  * diff * vec3(texture(material.diffuse, TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    return (ambient + diffuse + specular);
	*/
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
    vertex_color = result;
}

