# 🔧 Maestros

Webapp pensada para usarse **desde el celular**, hecha con Flask, que busca y extrae (*scraping*) datos de trabajadores especializados como gasfíteres, electricistas o carpinteros, y permite gestionarlos en un solo lugar. Incluye paneles CRUD de usuarios y de maestros.

▶️ **[Ver video demostrativo](https://youtu.be/u88tU756AyQ)** · 🌐 **[Ver en mi portafolio](https://marcogonzalez0.github.io/proyectos/maestro/)**

## ✨ Funcionalidades

- 🔍 **Búsqueda automatizada** de maestros por oficio y comuna, mediante scraping de [Yapo.cl](https://www.yapo.cl/).
- 📞 **Extracción de nombre y teléfono** de cada resultado.
- 🗂️ **Gestión por secciones:** guarda los maestros encontrados y muévelos entre secciones a medida que avanzas en la contratación.
- 🛠️ **CRUD de maestros y de usuarios**, con panel de administración.
- 👤 **Registro e inicio de sesión** con sesiones del lado del servidor.
- 📱 **Diseño móvil**, para consultarlo desde el celular.

## 🗃️ Versiones

| Versión | Rama | Scraping | Estado |
|---|---|---|---|
| **v3** | `v3` (por defecto) | **LXML + Playwright** | ⚡ Versión actual: más rápida y optimizada. |
| v2 | `v2` | Selenium | Versión intermedia. |
| v1 | `main` | Selenium | Más lenta: levanta un navegador completo por cada búsqueda. |

## 🧰 Tecnologías

| Área | Tecnologías |
|---|---|
| Backend | Python, Flask, Flask-Session |
| Base de datos | MySQL (`mysqlclient` / Flask-MySQLdb) |
| Scraping | Playwright y LXML |
| Frontend | HTML, CSS, JavaScript |

## 🚀 Instalación

**Requisitos:** Python 3, MySQL en el puerto `3306` (con MySQL Workbench, XAMPP o similar) y Git.

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/MarcoGonzalez0/Maestros.git
   cd Maestros
   ```

2. **Crea y activa un entorno virtual:**
   ```bash
   python -m venv venv
   .\venv\Scripts\activate
   ```

3. **Instala las dependencias y el navegador de Playwright:**
   ```bash
   pip install -r requirements.txt
   playwright install chromium
   ```

4. **Crea la base de datos** ejecutando el script [`BDD.sql`](BDD.sql) en tu servidor MySQL.

5. **Configura las variables de entorno:** copia [`.env.example`](.env.example) como `.env` y completa los valores.
   ```bash
   copy .env.example .env
   ```
   | Variable | Descripción |
   |---|---|
   | `SECRET_KEY` | Clave para firmar las sesiones. Genera una con `python -c "import secrets; print(secrets.token_hex(32))"`. |
   | `MYSQL_PASSWORD` | Contraseña de tu usuario de MySQL. |
   | `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_DB` | Opcionales. Por defecto: `localhost`, `3306`, `root`, `maestros`. |

6. **Inicia la aplicación:**
   ```bash
   flask run
   ```

7. Abre <http://localhost:5000> en el navegador.

## 🔑 Acceso de prueba

Puedes registrarte en la app o usar el usuario predeterminado:

| Usuario | Contraseña |
|---|---|
| `user` | `user` |

> ⚠️ Es una cuenta de demostración, pensada solo para uso local.

## ⚖️ Aviso

Proyecto con fines **educativos y de portafolio**. El scraping depende de la estructura de un sitio de terceros, por lo que puede dejar de funcionar si cambia. Si lo usas, respeta los términos de uso del sitio consultado.

## 👤 Autor

**Marco González** · [GitHub](https://github.com/MarcoGonzalez0) · [Portafolio](https://marcogonzalez0.github.io/)
