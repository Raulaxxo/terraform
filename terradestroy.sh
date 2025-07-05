#!/bin/bash
cd aws

folders=("alb" "ec2" "vpc")  # Cambia estos nombres por tus carpetas reales

for dir in "${folders[@]}"; do
  echo "=============================="
  echo "Ejecutando Terraform en $dir"
  echo "=============================="
  
  if [ -d "$dir" ]; then
    cd "$dir" || { echo "No se pudo entrar a $dir"; exit 1; }
    
    terraform init
    terraform destroy -auto-approve
    
    cd - > /dev/null
  else
    echo "Carpeta $dir no existe"
  fi
done
