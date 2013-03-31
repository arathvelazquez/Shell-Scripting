#!/bin/bash

timest=$(date +%s);
awk -v tmst=${timest} -F, 'BEGIN {foo=214}{foo+=1; if($15==""){test=$20;}; print "INSERT INTO users VALUES \
(\""foo"\",\"127.0.0.1\",\""$3" "$4"\",\"59beecdf7fc966e2f17fd8f65a4a9aeb09d4a3d4\", NULL,\""$15""test"\", NULL, NULL, NULL, NULL, "tmst", "tmst", 1, \""$3"\" , \""$4"\" ,\"familia\",\"\"); \n\
INSERT INTO users_groups (user_id, group_id) VALUES (\""foo"\", \"4\"); \n\
INSERT INTO alumnos \
(id, nombre, apellido_pat, apellido_mat, curp, fecha_nac, fecha_ingreso, direccion, telefono, grado, grupo) \
VALUES (\""foo"\",\""$5"\",\""$3"\",\""$4"\",\""$6"\",\""$7"\",\""$8"\",\""$9"\",\""$10"\",\""$1"\",\""$2"\");\n\
INSERT INTO alumnos_users (alumno_id, user_id) VALUES (\""foo"\", \""foo"\"); \n\
INSERT INTO padres (tipo, nombre, ocupacion, telefono, user_id) VALUES (\"madre\", \""$11"\" , \""$12"\" , \"Oficina: "$13" - Cel: "$14"\", \""foo"\"); \n\
INSERT INTO padres (tipo, nombre, ocupacion, telefono, user_id) VALUES (\"padre\", \""$16"\" , \""$17"\" , \"Oficina: "$18" - Cel: "$19"\", \""foo"\"); \n\n \
"}' $1;