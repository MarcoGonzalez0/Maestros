MAESTROS  
Webapp diseñada para usarse en dispositivos móviles, app hecha con flask con scraping avanzado (LXML, Playwright) para extracción y gestión de datos de trabajadores especializados. Paneles CRUD de gestión de usuarios y trabajadores.  
La v1 del pryecto usa Selenium por lo que es mas lenta. La versión 3 usa LXML con Playwright por lo que está optimizada.
1. Clonar proyecto a carpeta deseada con: git clone https://github.com/MarcoGonzalez0/Maestros.git, si se quiere clonar la v3(mas rapida) hacerlo con: git clone -b v3 https://github.com/MarcoGonzalez0/Maestros.git
3. Crear virtual environment dentro de la carpeta descargada: python -m venv venv
4. Activar venv: .\venv\Scripts\activate
5. Instalar dependencias necesarias a través de requirements.txt: pip install -r requirements.txt
6. La base de datos MySQL está por defecto en el puerto 3306, usen cualquier programa para levantarla ahí. Yo la desplego usando MySQL workbench pero puedes usar XAMPP. Usar el archivo BDD.sql en el directorio principal.
7. Escribir 'flask run' en la consola. Ahora la app está corriendo.
8. En el navegador ir al puerto 5000 que es donde corre la app: http://localhost:5000.
9. Pueden registrarse en la app, o utilizar nombre de usuario predeterminado: user y contraseña: user.
