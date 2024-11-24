document.addEventListener('DOMContentLoaded', () => {
    const navLinks = document.querySelectorAll('.navlink');

    navLinks.forEach(link => {
        link.addEventListener('click', (event) => {
            event.preventDefault(); // Prevent default anchor behavior
            
            const menuId = link.getAttribute('data-menu');
            showMenu(menuId);
        });
    });
});

function showMenu(menuId) {
    // Hide all menus
    const menus = document.querySelectorAll('.menu');
    menus.forEach(menu => {
        menu.style.display = 'none'; // or menu.classList.remove('active');
    });

    // Show the selected menu
    const activeMenu = document.getElementById(menuId);
    if (activeMenu) {
        activeMenu.style.display = 'block'; // or activeMenu.classList.add('active');
    }
}

// boton mostrar mas
document.addEventListener('DOMContentLoaded', function() {
    const botonesVerTelefono = document.querySelectorAll('.ver-telefono');
    
    botonesVerTelefono.forEach(boton => {
        boton.addEventListener('click', function() {
           
            const link = boton.getAttribute('data-link');
            const card = boton.closest('.card');
            const telefonoElemento = card.querySelector('.telefono');
            const nombreElemento = card.querySelector('.nombre');
            const botonAgregar = card.querySelector('.agregar'); // Seleccionar el botón "Agregar"

            fetch('/obt_telynom', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    'link': link
                })
            })
            .then(response => response.json())
            .then(data => {
                // Mostrar teléfono
                if (data.telefono) {
                    telefonoElemento.textContent = data.telefono;
                } else {
                    telefonoElemento.textContent = "Sin teléfono";
                }
                telefonoElemento.style.display = 'block';
                
                // Mostrar nombre
                if (data.nombre) {
                    nombreElemento.textContent = data.nombre;
                } else {
                    nombreElemento.textContent = "Sin nombre";
                }
                nombreElemento.style.display = 'block';
                
                // Ocultar el botón "Ver teléfono" después de recibir los datos
                boton.style.display = 'none';
                botonAgregar.style.display = 'inline-block'; // Mostrar el botón "Agregar"
            })
            .catch(error => console.error('Error:', error));
        });
    });
});



// boton agregar
document.addEventListener('DOMContentLoaded', function() {
    const botonesAgregar = document.querySelectorAll('.agregar');
    
    botonesAgregar.forEach(boton => {
        boton.addEventListener('click', function() {
            const card = boton.closest('.card');
            
            // Obtener todos los datos del artículo
            const nombreMaestro = card.querySelector('.nombre').textContent; // Nombre del maestro desde .nombre
            const tituloArticulo = card.querySelector('.titulo').textContent; // Título del artículo desde .card-title
            const descripcionMaestro = card.querySelector('.descripcion').textContent; // Descripción (puedes especificar otro selector si hay más elementos card-text)
            const location = card.querySelector('.card-text small').textContent; // Ubicación (lo que esté en <small>)
            
            // Obtener el teléfono (si es visible)
            const telefono = card.querySelector('.telefono').textContent;
            const mensaje = card.querySelector('.mensaje');
            
            // Enviar la solicitud POST al endpoint Flask
            fetch('/agregar_maestro', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    nombreMaestro,
                    tituloArticulo, // Agregar el título del artículo
                    descripcionMaestro,
                    location, // Incluimos la ubicación también
                    telefono
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    
                    // Aquí puedes hacer algo más, como ocultar el botón o mostrar una confirmación

                    boton.style.display = 'none'; // Ocultar el botón "Agregar maestro"
                    mensaje.textContent = data.message

                } else {

                    mensaje.textContent = data.message
                }
            })
            .catch(error => console.error('Error:', error));
        });
    });
});












document.addEventListener('DOMContentLoaded', function () {
    const editarBtn = document.querySelector('.boton.editar');
    const eliminarBtn = document.querySelector('.boton.eliminar');
    const moverBtn = document.querySelector('.boton.mover');
    const refrescarBtn = document.querySelector('.boton.refrescar'); // Nuevo botón
    const popup = document.getElementById('popup-confirmacion');
    const btnSi = document.getElementById('btn-si');
    const btnNo = document.getElementById('btn-no');

    // Deshabilitar botones al inicio
    editarBtn.disabled = true;
    eliminarBtn.disabled = true;
    moverBtn.disabled = true;

    // Variable para almacenar el maestro seleccionado
    let maestroSeleccionado = null;

    // Cargar los maestros de la API y llenar las tablas
    function cargarMaestros() {
        fetch('/maestros')
            .then(response => response.json())
            .then(data => {
                mostrarMaestros(data.todos, 'Todos');
                mostrarMaestros(data.en_revision, 'EnRevision');
                mostrarMaestros(data.seleccionados, 'Seleccionados');
            })
            .catch(error => console.error('Error:', error));
    }

    // Llamar a cargar maestros al inicio
    cargarMaestros();

    function mostrarMaestros(maestros, tab) {
        const tabla = document.querySelector(`#tabla-${tab.toLowerCase()} tbody`);
        tabla.innerHTML = ''; // Limpiar tabla

        maestros.forEach(maestro => {
            const fila = document.createElement('tr');
            fila.innerHTML = `
                <td>${maestro.idMaestro}</td>
                <td>${maestro.nombreMaestro}</td>
                <td>${maestro.titulo_especialidad}</td>
                <td>${maestro.descripcionMaestro}</td>
                <td>${maestro.comuna}</td>
                <td>${maestro.email}</td>
                <td>${maestro.telefono}</td>
            `;

            // Evento para seleccionar maestro
            fila.addEventListener('click', (event) => {
                event.stopPropagation(); // Evitar que el clic se propague
                seleccionarMaestro(fila, maestro);
            });

            tabla.appendChild(fila);
        });

        // Deshabilitar botones al cargar los datos de una nueva tabla
        deshabilitarBotones();
    }

    function seleccionarMaestro(fila, maestro) {
        // Quitar la selección de cualquier fila previamente seleccionada
        document.querySelectorAll('tr.selected').forEach(row => row.classList.remove('selected'));

        // Resaltar la fila seleccionada
        fila.classList.add('selected');

        // Actualizar maestro seleccionado
        maestroSeleccionado = maestro;

        // Habilitar botones según la pestaña activa
        const activeTab = document.querySelector('.tab-pane.active').id;

        editarBtn.disabled = false;
        eliminarBtn.disabled = false;

        // Verificar si estamos en la pestaña 'Todos' y deshabilitar el botón 'Mover'
        if (activeTab === 'Todos') {
            moverBtn.disabled = true;
        } else {
            moverBtn.disabled = false; // Habilitar 'Mover' si no estamos en la pestaña 'Todos'
        }

        console.log('Maestro seleccionado:', maestroSeleccionado);
    }

    function deshabilitarBotones() {
        editarBtn.disabled = true;
        eliminarBtn.disabled = true;
        moverBtn.disabled = true;
        maestroSeleccionado = null; // Limpiar maestro seleccionado
    }

    // Manejar el clic en el botón Refrescar
    refrescarBtn.addEventListener('click', function () {
        console.log('Refrescando datos...');
        cargarMaestros(); // Recargar datos de la API
    });










    // Función para manejar el cambio de pestaña
    window.openTab = function (evt, tabName) {
        // Ocultar todas las pestañas
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName('tab-pane');
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].classList.remove('active');
        }

        // Desmarcar todos los enlaces de las pestañas
        tablinks = document.getElementsByClassName('tablinks');
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].classList.remove('active');
        }

        // Mostrar la pestaña activa y añadir la clase "active"
        document.getElementById(tabName).classList.add('active');
        evt.currentTarget.classList.add('active');

        // Actualizar el id del campo de búsqueda para coincidir con la pestaña activa
        const searchInput = document.querySelector('.search-container input');
        searchInput.setAttribute('id', `search-${tabName.toLowerCase()}`); // Cambiar el id del input
        searchInput.value = ''; // Limpiar el valor del input al cambiar de pestaña

        // Realizar la búsqueda en la nueva pestaña
        buscarMaestro();

        // Deshabilitar botones al cambiar de pestaña (si es necesario)
        deshabilitarBotones();
    };

    // Función para buscar maestros dentro de la pestaña activa
    window.buscarMaestro = function () {
        // Obtener el nombre de la pestaña activa
        const tabActiva = document.querySelector('.tablinks.active').textContent.replace(/\s+/g, '').toLowerCase();
        const input = document.getElementById(`search-${tabActiva}`); // Usar el id correspondiente de la pestaña activa
        const filtro = input.value.toLowerCase();

        // Seleccionar la tabla correspondiente a la pestaña activa
        const tabla = document.querySelector(`#tabla-${tabActiva} tbody`);
        
        if (!tabla) return; // Si no hay tabla, no hacer nada
        
        const filas = tabla.getElementsByTagName('tr');
        Array.from(filas).forEach(fila => {
            const celdas = fila.getElementsByTagName('td');
            const texto = Array.from(celdas).map(celda => celda.textContent.toLowerCase()).join(' ');

            if (texto.includes(filtro)) {
                fila.style.display = ''; // Mostrar la fila
            } else {
                fila.style.display = 'none'; // Ocultar la fila
            }
        });
    };

    // Inicializar la pestaña activa cuando se carga la página
    document.addEventListener('DOMContentLoaded', () => {
        const activeTab = document.querySelector('.tablinks.active');
        if (activeTab) {
            const tabName = activeTab.textContent.trim().toLowerCase(); // Obtener el nombre de la pestaña activa
            openTab({ currentTarget: activeTab }, tabName); // Abrir la pestaña activa
        }
    });










    // Función para mover el maestro
    moverBtn.addEventListener('click', function () {
        if (maestroSeleccionado) {
            const nuevaSeccion = maestroSeleccionado.seccion === 'e' ? 's' : 'e'; // Cambiar de 'e' a 's' o viceversa

            // Actualizar la sección del maestro
            fetch(`/maestros/${maestroSeleccionado.idMaestro}/mover`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ seccion: nuevaSeccion })
            })
            .then(response => response.json())
            .then(data => {
                // Recargar maestros después de mover
                console.log(`Maestro movido a ${nuevaSeccion === 'e' ? 'En Revisión' : 'Seleccionados'}`);
                cargarMaestros(); // Actualizar las tablas
            })
            .catch(error => console.error('Error al mover maestro:', error));
        }
    });

    // Agregar evento global para deseleccionar al hacer clic fuera de las filas o botones o modal
    document.addEventListener('click', function (event) {
        const isClickDentroDeFila = event.target.closest('tr');
        const isClickEnBoton = event.target.closest('.boton');
        const isClickDentroDelModal = event.target.closest('#modal-editar-maestro');

        if (!isClickDentroDeFila && !isClickEnBoton&& !isClickDentroDelModal) {
            deshabilitarBotones(); // Deshabilitar botones y deseleccionar maestro si clic en otro lado
            document.querySelectorAll('tr.selected').forEach(row => row.classList.remove('selected'));
        }
    });


    
    // Abrir el modal
    function abrirModal(maestro) {
        const modal = document.getElementById("modal-editar-maestro");
        modal.style.display = "flex";

        // Rellenar los campos del formulario con los datos del maestro
        document.getElementById("nombre").value = maestro.nombreMaestro;
        document.getElementById("titulo").value = maestro.titulo_especialidad;
        document.getElementById("descripcion").value = maestro.descripcionMaestro;
        document.getElementById("comuna").value = maestro.comuna;
        document.getElementById("email").value = maestro.email;
        document.getElementById("telefono").value = maestro.telefono;
    }

    // Cerrar el modal
    function cerrarModal() {
        const modal = document.getElementById("modal-editar-maestro");
        modal.style.display = "none";
    }

    // Guardar cambios
    function guardarCambios() {

        
        if (!maestroSeleccionado) return;

        const datosActualizados = {
            nombreMaestro: document.getElementById("nombre").value,
            titulo_especialidad: document.getElementById("titulo").value,
            descripcionMaestro: document.getElementById("descripcion").value,
            comuna: document.getElementById("comuna").value,
            email: document.getElementById("email").value,
            telefono: document.getElementById("telefono").value,
            
        };


        // Validar los campos antes de proceder
        if (datosActualizados.nombreMaestro.length > 60) {
            alert("El nombre no puede tener más de 60 caracteres.");
            return;
        }
        if (datosActualizados.comuna.length > 100) {
            alert("La comuna no puede tener más de 100 caracteres.");
            return;
        }
        
        const telefonoRegex = /^\+?[0-9]{0,15}$/;
        if (!telefonoRegex.test(datosActualizados.telefono)) {
            alert("El teléfono no puede tener más de 15 caracteres y solo puede incluir el símbolo '+'.");
            return;
        }

        fetch(`/maestros_update/${maestroSeleccionado.idMaestro}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(datosActualizados)
        })
            .then(response => {
                if (!response.ok) {
                    // Si la respuesta no es OK, intenta obtener el mensaje de error
                    return response.json().then(errorData => {
                        throw new Error(errorData.error || "Error desconocido del servidor.");
                    });
                }
                return response.json(); // Procesar respuesta exitosa
            })
            .then(data => {
                alert(data.message || "Maestro actualizado correctamente.");
                cerrarModal();
                cargarMaestros(); // Actualizar las tablas
            })
            .catch((error) => {
                console.error(error);
                alert("Hubo un error al guardar los cambios: " + error.message + error.details);
            });

    }


    

    // Hacer las funciones globales
    window.cerrarModal = cerrarModal;
    window.guardarCambios = guardarCambios;

    // Manejar clic en el botón Editar
    editarBtn.addEventListener("click", function () {
        if (!maestroSeleccionado) {
            alert("Por favor, selecciona un maestro.");
            return;
        }
        abrirModal(maestroSeleccionado);
    });




    // manejar boton eliminar

    eliminarBtn.addEventListener('click', function() {
        if (maestroSeleccionado) {
            popup.style.display = 'flex'; // Mostrar el popup
        } else {
            alert("Por favor, selecciona un maestro antes de eliminar.");
        }
    });
    
    // Función para manejar el clic en "Sí"
    btnSi.addEventListener('click', function() {
        if (maestroSeleccionado) {
            // Enviar el ID del maestro al backend (Flask)
            fetch(`/eliminar_maestro/${maestroSeleccionado.idMaestro}`, {
                method: 'DELETE', // Usamos DELETE para eliminar
                headers: {
                    'Content-Type': 'application/json',
                }
            })
            .then(response => response.json())
            .then(data => {
                alert(data.message || "Maestro eliminado correctamente.");
                // Cerrar el popup y actualizar los datos
                popup.style.display = 'none';
                cargarMaestros(); // Recargar la lista de maestros
            })
            .catch(error => {
                console.error(error);
                alert("Hubo un error al eliminar al maestro.");
            });
        }
    });
    
    // Función para manejar el clic en "No"
    btnNo.addEventListener('click', function() {
        popup.style.display = 'none'; // Cerrar el popup
    });

    // Función para cerrar el popup si se hace clic fuera de él
    document.addEventListener('click', function(event) {
        // Verificar si el clic fue fuera del popup y sus contenidos
        if (!popup.contains(event.target) && event.target !== eliminarBtn) {
            popup.style.display = 'none'; // Cerrar el popup si clic fuera de él
        }
    });






});
