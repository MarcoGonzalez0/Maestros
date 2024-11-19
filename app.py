from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify, json
from flask_mysqldb import MySQL
import MySQLdb
from MySQLdb import OperationalError
import re
from selenium import webdriver
from selenium.webdriver import Chrome
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.webdriver.common.by import By
from time import sleep
from flask_session import Session  # Importa Flask-Session

app = Flask(__name__)

# Configura la clave secreta
app.secret_key = 'coldplay'

# Configura la base de datos
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_PORT'] = 3306
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '12345'
app.config['MYSQL_DB'] = 'maestros'

# Configura Flask-Session para almacenar sesiones en el servidor
app.config['SESSION_TYPE'] = 'filesystem'  # Almacenar en el sistema de archivos
app.config['SESSION_PERMANENT'] = False
app.config['SESSION_USE_SIGNER'] = True
Session(app)

# Inicializa MySQL
mysql = MySQL(app)

@app.before_request
def check_request():
    if request.endpoint in ['login', 'registro', 'static', 'favicon', 'favicon.ico']:
        return None
    if 'loggedin' not in session:
        return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        username = request.form['username']
        password = request.form['password']

        try:
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute('SELECT * FROM Acceso JOIN Usuario ON Acceso.Usuario_idUsuario = Usuario.idUsuario WHERE username = %s AND llave = %s', (username, password))
            cuenta = cursor.fetchone()

            
            if cuenta:
                # Validar estado de acceso
                if cuenta["estadoAcceso"] != 1:
                    flash("Su acceso está denegado!", "danger")
                    return redirect(url_for('login'))
                
                session['loggedin'] = True
                session['id'] = cuenta['idAcceso']
                session['username'] = cuenta['username']
                session['tipo_usuario'] = cuenta['Tipo_Usuario_idTipo']  # Guardamos el tipo de usuario en la sesión
                return redirect(url_for('index'))
            else:
                flash("Usuario o contraseña incorrecta!!", "danger")
        
        except OperationalError as e:
            flash(f"Error al conectar con la base de datos: {e}", "danger")
            return redirect(url_for('login'))
        
        except Exception as e:
            flash(f"Ocurrió un error inesperado: {e}", "danger")
            return redirect(url_for('login'))

    return render_template('login.html')



@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if request.method == 'POST' and \
       'nombre' in request.form and \
       'apellido_paterno' in request.form and \
       'apellido_materno' in request.form and \
       'direccion' in request.form and \
       'email' in request.form and \
       'comuna' in request.form and \
       'telefono' in request.form and \
       'username' in request.form and \
       'password' in request.form and \
       'repetir_password' in request.form:
        
        nombre = request.form['nombre']
        appat = request.form['apellido_paterno']
        appmat = request.form['apellido_materno']
        direccion = request.form['direccion']
        email = request.form['email']
        comuna = request.form['comuna']
        telefono = request.form['telefono']
        username = request.form['username']
        password = request.form['password']
        rep_password = request.form['repetir_password']

        try:
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            
            patron = "%" + comuna + "%"
            cursor.execute("SELECT * FROM Comuna WHERE nombreComuna LIKE %s", [patron])
            idcomuna = cursor.fetchone()

            cursor.execute("SELECT * FROM Acceso WHERE username LIKE %s", [username])
            cuenta = cursor.fetchone()

            if cuenta:
                flash("Este nombre de usuario ya existe!", "danger")
            elif not re.match(r'^[A-Za-z0-9]+$', username):
                flash("El nombre de usuario solo debe contener letras y números.", "danger")
            elif password != rep_password:
                flash("Las contraseñas no coinciden, intentalo de nuevo.")
            else:
                if idcomuna:
                    comuna = idcomuna['idComuna']
                else:
                    comuna = None

                cursor.execute('CALL sp_InsertarUsuarioyAcceso(%s, %s, %s,%s, %s, %s, %s, %s, %s,%s)', (nombre, appat, appmat, direccion, email, comuna, telefono, username, password,1))
                flash("Te has registrado satisfactoriamente!", "success")
                mysql.connection.commit()
                return render_template('registro.html')
        
        except OperationalError as e:
            flash(f"Error al conectar con la base de datos: {e}", "danger")
            return render_template('registro.html')
        
        except Exception as e:
            flash(f"Ocurrió un error inesperado: {e}", "danger")
            return render_template('registro.html')

    return render_template('registro.html')

@app.route('/')
def index():
    if 'loggedin' in session:
        # Obtener solo datos esenciales de la sesión
        resultados = session.get('resultados_scraping', [])
        return render_template('index.html', username=session['username'], articulos=resultados)
    return redirect(url_for('login'))

@app.route('/logout', methods=['POST'])
def logout():
    session.pop('loggedin', None)
    session.pop('id', None)
    session.pop('username', None)
    session.pop('resultados_scraping', None)  # Limpiar los resultados al salir
    flash("¡Has cerrado sesión correctamente!", "success")
    return redirect(url_for('login'))



@app.route('/scrap', methods=['GET', 'POST'])
def scrap():
   
    service = Service(ChromeDriverManager().install())
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--window-size=1920,1080")
    driver = webdriver.Chrome(service=service, options=options)
    
    if request.method == 'POST' and 'query' in request.form:
        consulta = request.form['query']
        ubicacion = request.form.get('location', '')  # 'location' es opcional

        try:
            # Navega al sitio de scraping
            driver.get("https://www.yapo.cl/")
            
            # Realiza la búsqueda
            driver.find_element(By.ID, "categorysearch_keyword").send_keys(consulta)
            driver.find_element(By.ID, "clonecategorysearch_region_clone").send_keys(ubicacion)
            
            if ubicacion:
                try:
                    select_region = Wait(driver, 7).until(
                        EC.presence_of_element_located((By.CLASS_NAME, "tt-selectable"))
                    )
                    select_region.click()
                except:
                    flash("Error al encontrar ubicación ingresada, asegúrese de escribir correctamente la comuna", "error")
                    return redirect(url_for('index'))
            
            # Buscar
            try:
                btn_buscar = Wait(driver, 7).until(
                    EC.presence_of_element_located((By.CLASS_NAME, "d3-button--filled"))
                )
                btn_buscar.click()
            except:
                flash("No se encontró el botón de búsqueda", "error")
                return redirect(url_for('index'))
            
            # Filtrar
            try:
                btn_filtro = Wait(driver, 7).until(
                    EC.element_to_be_clickable((By.CLASS_NAME, "d3-select"))
                )
                driver.execute_script("arguments[0].click();", btn_filtro)
                sleep(1)
                opciones = driver.find_elements(By.TAG_NAME, "option")
                for opcion in opciones:
                    if opcion.text == "Más recientes":
                        opcion.click()
                        break
            except Exception as e:
                flash("No se encontraron resultados", "error")
                return redirect(url_for('index'))
            
            # Extraer datos
            
            container = Wait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, "d3-ads-grid--category-list"))
            )
            articulos = container.find_elements(By.CLASS_NAME, "d3-ad-tile")



            resultados = []  # Lista para almacenar solo datos esenciales
            
            for art in articulos:
                try:
                    location = art.find_element(By.CLASS_NAME, "d3-ad-tile__location").text
                    titulo = art.find_element(By.CLASS_NAME, "d3-ad-tile__title").text
                    descripcion = art.find_element(By.CLASS_NAME, "d3-ad-tile__short-description").text
                    link = art.find_element(By.CLASS_NAME, "d3-ad-tile__title").get_attribute("href")

                    if descripcion == "":
                        descripcion = "Sin descripcion"

                    resultados.append({
                        "location": location,
                        "titulo": titulo,
                        "descripcion": descripcion,
                        "link": link
                    })

                except Exception as e:
                    print(f"Error procesando artículo: {e}")
            
            # Guardar los resultados esenciales en la sesión
            session['resultados_scraping'] = resultados
            driver.quit()
            return redirect(url_for('index'))

        except Exception as e:
            flash(f"Error en el proceso de scraping: {e}", "error")
            return redirect(url_for('index'))
        
    return render_template('index.html')


@app.route('/obt_telynom', methods=['POST'])
def obt_telynom():
    service = Service(ChromeDriverManager().install())
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--window-size=1920,1080")
    driver = webdriver.Chrome(service=service, options=options)

    if 'resultados_scraping' in session:
        # Obtén el link del artículo desde el formulario POST
        url_articulo = request.form.get('link')
        
        # Navegar a la URL del artículo
        driver.get(url_articulo)

        # Aquí puedes hacer scraping directamente en la página del artículo
        try:

            nombre=""
            telefono=""
            
            #obtener nombre
            nombre_ = Wait(driver, 10).until(
                EC.presence_of_element_located((By.XPATH, '//a[contains(@href, "/user/profile/id/")]'))
            )
            nombre = nombre_.text

            Wait(driver, 10).until(
                EC.presence_of_element_located((By.CLASS_NAME, "d3-property-contact__see-phone"))
            )

            # Obtener el teléfono
            btn_ver_telefono = driver.find_element(By.CLASS_NAME, "d3-property-contact__see-phone")
            driver.execute_script("arguments[0].click();", btn_ver_telefono)

            telefono_ = Wait(driver, 10).until(
                EC.presence_of_element_located((By.XPATH, "//a[starts-with(@href, 'tel:')]"))
            )
            telefono = telefono_.text

            # Retornar los detalles al usuario como JSON
            return jsonify({"telefono": telefono, "nombre":nombre})

        except Exception as e:
                       
            return jsonify({"error": f"No se pudo obtener el telefono o el nombre: {e}", "nombre":nombre, "telefono":telefono})
    else:
        driver.quit()
        return jsonify({"error": "No se encontraron resultados en la sesión"})
    


@app.route('/agregar_maestro', methods=['POST'])
def agregar_maestro():
    if request.method == 'POST':
        try:
            # Obtener los datos enviados en formato JSON
            data = request.get_json()

            # Obtener los valores del JSON
            nombre = data.get('nombreMaestro')
            descripcion = data.get('descripcionMaestro')

            especialidad = data.get('tituloArticulo')
            titulo_esp = data.get('tituloArticulo')

            location = data.get('location')
            telefono = data.get('telefono')

            # Manejar comuna
            patronC = "%" + location + "%"
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute("SELECT * FROM Comuna WHERE nombreComuna LIKE %s", [patronC])
            idcomuna = cursor.fetchone()

            if idcomuna:
                comuna = idcomuna['idComuna']
            else:
                comuna = None

            # Manejar especialidad
            patronE = "%" + especialidad + "%"
            cursor.execute("SELECT * FROM Especialidad WHERE nombreEspecialidad LIKE %s", [patronE])
            idespe = cursor.fetchone()

            if idespe:
                especialidad = idespe['idEspecialidad']
            else:
                especialidad = None


            cursor.execute('SELECT * FROM Maestro m, Telefonos_Maestros tm WHERE nombreMaestro = %s AND  numero= %s', (nombre, telefono))
            maestroRepetido = cursor.fetchone()


            if maestroRepetido:
                
                return jsonify({"success": False, "message":"Este maestro ya existe en el sistema"})
            
            else:
                # Llamar al procedimiento almacenado para insertar datos
                cursor.execute('CALL sp_InsertarMaestroYTelefono(%s, %s, %s, %s, %s, %s, %s, %s, %s)', 
                            (nombre, titulo_esp, descripcion, comuna, especialidad, 'e', "Sin email", "Sin direccion", telefono))

                # Confirmación de éxito
                mysql.connection.commit()
                
                return jsonify({"success": True, "message":"Datos ingresados!"})


        except OperationalError as e:
            print(f"Error al conectar con la base de datos: {e}")
            return jsonify({"success": False, "message": "Error al conectar con la base de datos"})

        except Exception as e:
            print(f"Ocurrió un error inesperado: {e}")
            return jsonify({"success": False, "message": "Ocurrió un error inesperado"})

    return jsonify({"success": False, "message": "Método no permitido"})



@app.route('/maestros', methods=['GET'])
def obtener_maestros():
    # Crear el cursor
    cur = mysql.connection.cursor()

    # Consulta SQL para obtener los maestros, sus comunas, teléfonos y secciones
    query = """
        SELECT m.idMaestro, m.nombreMaestro, m.titulo_especialidad, m.descripcionMaestro,
               c.nombreComuna, m.email, t.numero AS telefono, m.seccion
        FROM Maestro m
        LEFT JOIN Comuna c ON m.Comuna_idComuna = c.idComuna
        LEFT JOIN Telefonos_Maestros t ON m.idMaestro = t.Maestro_idMaestro
    """
    
    cur.execute(query)
    
    # Obtener todos los resultados de la consulta
    maestros = cur.fetchall()

    # Lista para almacenar los resultados
    maestros_data = []

    # Recorrer los resultados y prepararlos para la respuesta JSON
    for maestro in maestros:
        maestro_data = {
            'idMaestro': maestro[0],
            'nombreMaestro': maestro[1],
            'titulo_especialidad': maestro[2],
            'descripcionMaestro': maestro[3],
            'comuna': maestro[4],  # Nombre de la comuna
            'email': maestro[5],
            'telefono': maestro[6],  # Número de teléfono
            'seccion': maestro[7]   # Mantenemos la sección solo para la lógica
        }
        maestros_data.append(maestro_data)

    # Cerrar el cursor
    cur.close()

    # Devolver los resultados como JSON, clasificando según la sección
    return jsonify({
        'todos': maestros_data,
        'en_revision': [m for m in maestros_data if m['seccion'] == 'e'],
        'seleccionados': [m for m in maestros_data if m['seccion'] == 's']
    })




@app.route('/maestros/<int:id_maestro>/mover', methods=['PATCH'])
def patch_maestro(id_maestro):
    try:
        # Obtener solo el campo 'seccion' del JSON enviado
        datos = request.get_json()
        nueva_seccion = datos.get('seccion')

        if not nueva_seccion:
            return jsonify({'error': 'El campo "seccion" es requerido'}), 400

        # Llamar a la función para actualizar solo la sección
        resultado = actualizar_maestro(id_maestro, nueva_seccion)

        if resultado is None:
            return jsonify({'error': 'Hubo un problema al actualizar el maestro'}), 500

        return jsonify({'error': 'Maestro actualizado con éxito', 'filas_afectadas': resultado})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def actualizar_maestro(id_maestro, nueva_seccion):
    """
    Actualiza solo la sección de un maestro en la base de datos.

    Args:
        id_maestro (int): ID del maestro a actualizar.
        nueva_seccion (str): Nueva sección para el maestro.

    Returns:
        int: Número de filas afectadas.
    """
    
    try:
        # Consulta preparada solo para actualizar la sección
        query = """
            UPDATE Maestro
            SET seccion = %s
            WHERE idMaestro = %s
        """

        # Ejecutar la consulta
        cur = mysql.connection.cursor()
        cur.execute(query, (nueva_seccion, id_maestro))

        # Commit de los cambios
        mysql.connection.commit()

        # Devolver el resultado
        return cur.rowcount

    except mysql.connector.Error as e:
        # Manejar errores de base de datos
        print(f"Error de base de datos: {e}")
        mysql.connection.rollback()
        return None






# PARA BOTON EDITAR Y UPDATEAR DATOS CON MODAL
@app.route('/maestros_update/<int:maestro_id>', methods=['PUT'])
def update_maestro(maestro_id):
    try:
        # Conectar a la base de datos
        
        cursor = mysql.connection.cursor()

        # Obtener los datos del request
        datos = request.get_json()
        nombreMaestro = datos.get('nombreMaestro')
        titulo_especialidad = datos.get('titulo_especialidad')
        descripcionMaestro = datos.get('descripcionMaestro')
        comuna = datos.get('comuna')
        email = datos.get('email')
        telefono = datos.get('telefono')


        # Manejar comuna
        patron = "%" + comuna + "%"
        cursor.execute("SELECT * FROM Comuna WHERE nombreComuna LIKE %s", [patron])
        idcomuna = cursor.fetchone()
        
        if idcomuna:
            idcomuna = idcomuna[0]
        else:
            idcomuna = None

        # Manejar especialidad
        patronE = "%" + titulo_especialidad + "%"
        cursor.execute("SELECT * FROM Especialidad WHERE nombreEspecialidad LIKE %s", [patronE])
        idespe = cursor.fetchone()

        if idespe:
            idespe = idespe[0]
        else:
            idespe = None

        # Llamar al procedimiento almacenado
        query = """
            CALL sp_ActualizarMaestro(
                %s, %s, %s, %s, %s, %s, %s, %s
            )
        """
        cursor.execute(query, (
            maestro_id, 
            nombreMaestro, 
            titulo_especialidad, 
            descripcionMaestro, 
            idcomuna, 
            email, 
            telefono,
            idespe
        ))

        # Confirmar los cambios
        mysql.connection.commit()

        # Responder con éxito
        return jsonify({'message': 'Maestro actualizado correctamente.'}), 200

    except Exception as e:
        # Manejo de errores en caso de falla en la base de datos
        
        return jsonify({'error': 'No se pudo actualizar el maestro.', 'details': str(e)}), 500
    




    

@app.route('/eliminar_maestro/<int:maestro_id>', methods=['DELETE'])
def eliminar_maestro(maestro_id):
    try:
        # Conectar a la base de datos
        cursor = mysql.connection.cursor()

        # Ejecutar el query para eliminar al maestro
        cursor.execute("DELETE FROM Maestro WHERE idMaestro = %s", (maestro_id,))

        # Confirmar los cambios
        mysql.connection.commit()

        return jsonify({'message': 'Maestro eliminado correctamente.'}), 200
    except MySQLdb.Error as e:
        print(f"Error al eliminar maestro: {e}")
        return jsonify({'error': 'No se pudo eliminar al maestro.', 'details': str(e)}), 500
    finally:
        cursor.close()






# ------------------------------------------------------------------------------------------------------------------------------------------










# ACA MANEJO EL CRUD DE USUARIOS
# Ruta para obtener los usuarios con la información de las tres tablas
@app.route('/users', methods=['GET'])
def get_users():
    try:
        cursor = mysql.connection.cursor()

        # Consulta SQL para obtener los usuarios con los datos de Tipo_Usuario y Acceso
        query = """
        SELECT u.idUsuario, u.nombre, u.appat, u.telefonoUsuario, DATE_FORMAT(u.fecha_reg, '%d/%m/%Y %H:%i:%s') AS fecha_reg, 
               tu.idTipo AS tipo_usuario, a.username, a.llave, a.diasCaducaLLave, a.estadoAcceso
        FROM Usuario u
        JOIN Tipo_Usuario tu ON u.Tipo_Usuario_idTipo = tu.idTipo
        LEFT JOIN Acceso a ON u.idUsuario = a.Usuario_idUsuario;
        """

        cursor.execute(query)
        users = cursor.fetchall()
        cursor.close()

        # Retorna los datos en formato JSON
        return jsonify(users)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


#para insertar
@app.route('/add-user', methods=['POST'])
def add_user():
    try:
        # Obtener los datos enviados en la solicitud
        data = request.get_json()
        nombre = data['nombre']
        appat = data['appat']
        apmat = data['apmat']  # Si no hay, se usa un valor vacío
        direccion = data['direccion']
        email = data['email']
        comuna = data['comuna']
        telefono = data['telefono']
        username = data['username']
        llave = data['llave']
        tipo_usuario = data['tipo_usuario']

 

        cursor = mysql.connection.cursor()

        patron = "%" + comuna + "%"
        cursor.execute("SELECT * FROM Comuna WHERE nombreComuna LIKE %s", [patron])
        idcomuna = cursor.fetchone()
        
        cursor.execute("SELECT * FROM Acceso WHERE username LIKE %s", [username])
        cuenta = cursor.fetchone()

        
        if cuenta:  
            return jsonify({"error": "Este nombre de usuario ya existe"}), 201
        else:
        
            if idcomuna:
                idcomuna = idcomuna[0]
            else:
                idcomuna = None    

            # Llamar al procedimiento almacenado
      
            cursor.callproc('sp_InsertarUsuarioyAcceso', [
                nombre, appat, apmat, direccion, email, idcomuna, telefono, username, llave, tipo_usuario
            ])
        
            # Confirmar cambios
            mysql.connection.commit()
            cursor.close()

            return jsonify({"success": True, "message": "Usuario agregado exitosamente"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    

    



#para updatear
@app.route('/edit-user', methods=['POST'])
def edit_user():
    try:
        # Obtener los datos enviados desde el cliente
        user_data = request.get_json()


        # Conectar a la base de datos

        cursor = mysql.connection.cursor()

        # Preparar la consulta para actualizar los datos
        update_query = """
        UPDATE Usuario 
        JOIN Acceso ON Usuario.idUsuario = Acceso.Usuario_idUsuario
        SET 
            Usuario.nombre = %s,
            Usuario.appat = %s,
            Usuario.email = %s,
            Usuario.telefonoUsuario = %s,
            Acceso.username = %s,
            Acceso.llave = %s,
            Usuario.Tipo_Usuario_idTipo = %s,
            Acceso.estadoAcceso = %s
        WHERE Usuario.idUsuario = %s;
        """
        cursor.execute(update_query, (
            user_data['nombre'],
            user_data['appat'],
            user_data['email'],
            user_data['telefono'],
            user_data['username'],
            user_data['llave'],
            user_data['tipo_usuario'],
            user_data['estado_acceso'],
            user_data['idUsuario']  # ID del usuario a editar
        ))

        # Confirmar los cambios
        mysql.connection.commit()

        # Cerrar la conexión
        # cursor.close()
        # mysql.connection.close()

        return jsonify({"success": True})
    except Exception as e:
        # Manejo de errores
        return jsonify({"success": False, "error": str(e)})


# para obtener datos usuario
@app.route('/get-user/<int:user_id>', methods=['GET'])
def get_user(user_id):
    try:
        # Realiza la consulta para obtener los datos del usuario, su tipo y acceso
        query = """
        SELECT u.nombre, u.appat, u.email, u.telefonoUsuario, u.Tipo_Usuario_idTipo, 
               a.username, a.llave, a.estadoAcceso
        FROM Usuario u
        JOIN Acceso a ON u.idUsuario = a.Usuario_idUsuario
        WHERE u.idUsuario = %s
        """

        cursor = mysql.connection.cursor()

        cursor.execute(query, (user_id,))
        user = cursor.fetchone()

        if user:
            # Si se encuentra el usuario, se devuelve en formato JSON
            user_data = {
                'nombre': user[0],  # nombre del usuario
                'appat': user[1],  # apellido paterno
                'email': user[2],  # email
                'telefono': user[3],  # teléfono
                'tipo_usuario': user[4],  # ID del tipo de usuario
                'username': user[5],  # nombre de usuario
                'llave': user[6],  # llave de acceso
                'estado_acceso': user[7]  # estado del acceso
            }
            return jsonify(user_data)
        else:
            return jsonify({'error': 'Usuario no encontrado'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    

#para eliminar
@app.route('/delete-user/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    try:
      
        cursor = mysql.connection.cursor()

        # Verificar si el usuario existe antes de eliminar
        cursor.execute("SELECT idUsuario FROM Usuario WHERE idUsuario = %s", (user_id,))
        if cursor.rowcount == 0:
            return jsonify({'message': 'Usuario no encontrado'}), 404

        # Eliminar el usuario
        cursor.execute("DELETE FROM Usuario WHERE idUsuario = %s", (user_id,))
        mysql.connection.commit()

        return jsonify({'message': 'Usuario eliminado con éxito'}), 200
    except Exception as e:
        print("Error al eliminar el usuario:", e)
        return jsonify({'message': 'Error al eliminar el usuario'}), 500
  


if __name__ == '__main__':
    app.run(debug=True)
