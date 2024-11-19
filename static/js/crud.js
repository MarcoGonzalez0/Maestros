// URL del endpoint para obtener los usuarios
const apiUrl = '/users';

// Función para refrescar la tabla de usuarios
const refreshTable = async () => {
    try {
        const response = await fetch(apiUrl);
        const users = await response.json();  // Obtener los datos en formato JSON
        const tableBody = document.querySelector('.user-table tbody');
        tableBody.innerHTML = '';  // Limpiar la tabla antes de insertar los nuevos datos

        // Insertar cada usuario como una fila de la tabla
        users.forEach(user => {
            const row = `
                <tr>
                    <td>${user[0]}</td>
                    <td>${user[1]}</td>
                    <td>${user[2]}</td>
                    <td>${user[3]}</td>
                    <td>${user[4]}</td>
                    <td>${user[5]}</td>
                    <td>${user[6]}</td>
                    <td>${user[7]}</td>
                    <td>${user[8]}</td>
                    <td>${user[9]}</td>
                    <td>
                        <button class="btn edit-btn" onclick="openEditModal(${user[0]})">Editar</button>
                        <button class="btn delete-btn" onclick="deleteUser(${user[0]})">Eliminar</button>
                    </td>
                </tr>
            `;
            tableBody.insertAdjacentHTML('beforeend', row);  // Insertar la fila en la tabla
        });
    } catch (error) {
        console.error('Error al cargar los usuarios:', error);
    }
};

// Llamar a la función para cargar la tabla de usuarios al cargar la página
document.getElementById('refresh-btn').addEventListener('click', refreshTable);

// Llamar a la función para cargar los usuarios automáticamente al cargar la página
window.onload = refreshTable;





// agregar usuario
// Abrir el modal
function openModal() {
    document.getElementById("add-user-modal").style.display = "block";
}

// Cerrar el modal
function closeModal() {
    document.getElementById("add-user-modal").style.display = "none";
}

// Enviar los datos al backend
document.getElementById('add-user-form').addEventListener('submit', async (event) => {
    event.preventDefault(); // Prevenir el comportamiento por defecto del formulario

    const userData = {
        nombre: document.getElementById('nombrec').value,
        appat: document.getElementById('appatc').value,
        apmat: document.getElementById('apmatc').value,
        direccion: document.getElementById('direccionc').value,
        email: document.getElementById('emailc').value,
        comuna: document.getElementById('comunac').value,
        telefono: document.getElementById('telefonoc').value,
        username: document.getElementById('usernamec').value,
        llave: document.getElementById('llavec').value,
        tipo_usuario: document.getElementById('tipo_usuarioc').value
    };

      

    // Validar que el número de teléfono solo contenga números y el símbolo '+'
    const phoneRegex = /^[+]?[0-9]+$/;

    if (userData.telefono.length > 15) {
        alert("El número de teléfono no puede tener más de 15 caracteres.");
        return;
    }

    if (!phoneRegex.test(userData.telefono)) {
        alert("El número de teléfono solo puede contener números y el símbolo '+'.");
        return;
    }

    // Validación del campo username (solo letras y números)
    const usernameRegex = /^[A-Za-z0-9]+$/;
    if (!userData.username.match(usernameRegex)) {
        alert("El nombre de usuario solo debe contener letras y números.");
        return;
    }

    // Validación del campo tipo_usuario (solo puede ser 1 o 2)
    if (userData.tipo_usuario !== '1' && userData.tipo_usuario !== '2') {
        alert("El tipo de usuario solo puede ser 1 o 2.");
        return;
    }

    try {
        const response = await fetch('/add-user', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userData)
        });

        const result = await response.json();
        if (result.success) {
            alert(result.message);  // Mensaje de éxito
            closeModal();  // Cerrar el modal
        } else {
            alert("Ha ocurrido un error inesperado: " + result.error);  // Mensaje de error
        }
    } catch (error) {
        console.error('Error al agregar el usuario:', error);
    }
});


//editar usuario
// Función para abrir el popup con los datos del usuario
function openEditModal(userId) {
    // Obtén los datos del usuario seleccionado (esto puede ser una llamada a la API o datos almacenados)
    fetch(`/get-user/${userId}`) // Suponiendo que tienes un endpoint para obtener el usuario
        .then(response => response.json())
        .then(data => {
            // Llenar el formulario con los datos del usuario
            document.getElementById('edit-id').value = userId; // Campo oculto para el ID
            document.getElementById('edit-nombre').value = data.nombre;
            document.getElementById('edit-appat').value = data.appat;
            document.getElementById('edit-email').value = data.email;
            document.getElementById('edit-telefono').value = data.telefono;
            document.getElementById('edit-username').value = data.username;
            document.getElementById('edit-llave').value = data.llave;
            document.getElementById('edit-tipo_usuario').value = data.tipo_usuario;
            document.getElementById('edit-estado').value = data.estado_acceso;
            
            // Mostrar el modal
            document.getElementById('edit-user-modal').style.display = 'block';
        })
        .catch(error => {
            console.error('Error al obtener los datos del usuario:', error);
        });
}

// Función para cerrar el popup
function closeEditModal() {
    document.getElementById('edit-user-modal').style.display = 'none';
}

// Función para editar usuario
function editUser() {
    const userData = {
        idUsuario: document.getElementById('edit-id').value,        
        nombre: document.getElementById('edit-nombre').value,
        appat: document.getElementById('edit-appat').value,
        email: document.getElementById('edit-email').value,
        telefono: document.getElementById('edit-telefono').value,
        username: document.getElementById('edit-username').value,
        llave: document.getElementById('edit-llave').value,
        tipo_usuario: document.getElementById('edit-tipo_usuario').value,
        estado_acceso: document.getElementById('edit-estado').value
    };

    // Validar los datos antes de enviarlos
    if (userData.telefono.length > 15) {
        alert("El número de teléfono no puede tener más de 15 caracteres.");
        return;
    }

    const phoneRegex = /^[+]?[0-9]+$/;
    if (!phoneRegex.test(userData.telefono)) {
        alert("El número de teléfono solo puede contener números y el símbolo '+'.");
        return;
    }

    if (!/^[A-Za-z0-9]+$/.test(userData.username)) {
        alert("El nombre de usuario solo debe contener letras y números.");
        return;
    }

    if (![1, 2].includes(parseInt(userData.tipo_usuario))) {
        alert("El tipo de usuario debe ser 1 o 2.");
        return;
    }

    if (![1, 0].includes(parseInt(userData.estado_acceso))) {
        alert("El estado de acceso debe ser 1 o 0.");
        return;
    }


    // Enviar los datos al backend
    fetch('/edit-user', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(userData)
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert("Usuario editado con éxito");
            closeEditModal();  // Cerrar el modal
            // Actualizar la tabla o interfaz para reflejar los cambios (opcional)
        } else {
            alert("Error al editar el usuario: " + result.error);
        }
    })
    .catch(error => {
        console.error('Error al editar el usuario:', error);
    });
}





// Función para eliminar un usuario
const deleteUser = async (userId) => {
    const confirmDelete = confirm('¿Estás seguro de que deseas eliminar este usuario?');
    if (!confirmDelete) return;

    try {
        const response = await fetch(`/delete-user/${userId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
        });

        if (response.ok) {
            alert('Usuario eliminado con éxito');
            await refreshTable(); // Actualizar la tabla después de eliminar
        } else {
            const errorData = await response.json();
            alert(`Error al eliminar el usuario: ${errorData.message}`);
        }
    } catch (error) {
        console.error('Error al eliminar el usuario:', error);
        alert('Error al eliminar el usuario. Por favor, inténtalo de nuevo.');
    }
};