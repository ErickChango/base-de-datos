// EduTech Academy - MongoDB
// Inserciones, Agregaciones y Consultas

// Insertar estudiantes
db.estudiantes.insertMany([
  {
    estudiante_id: 1,
    nombre: "Juan",
    apellido: "Perez",
    correo: "juan@gmail.com",
    cursos_matriculados: [1, 2]
  },
  {
    estudiante_id: 2,
    nombre: "Maria",
    apellido: "Lopez",
    correo: "maria@gmail.com",
    cursos_matriculados: [1]
  },
  {
    estudiante_id: 3,
    nombre: "Pedro",
    apellido: "Gomez",
    correo: "pedro@gmail.com",
    cursos_matriculados: [2]
  }
]);

// Insertar cursos con valoraciones embebidas
db.cursos.insertMany([
  {
    curso_id: 1,
    nombre: "Programacion",
    descripcion: "Fundamentos de programacion",
    valoraciones: [
      { estudiante_id: 1, comentario: "Muy buen curso", puntuacion: 5, fecha: new Date("2026-10-20") },
      { estudiante_id: 2, comentario: "Me gustaron las clases", puntuacion: 4, fecha: new Date("2026-10-21") }
    ]
  },
  {
    curso_id: 2,
    nombre: "Base de Datos",
    descripcion: "Introduccion a las bases de datos",
    valoraciones: [
      { estudiante_id: 1, comentario: "Aprendi bastante", puntuacion: 5, fecha: new Date("2026-10-22") },
      { estudiante_id: 3, comentario: "Buen contenido", puntuacion: 4, fecha: new Date("2026-10-23") }
    ]
  }
]);

// Valoraciones del curso 1
db.cursos.aggregate([
  { $match: { curso_id: 1 } },
  { $unwind: "$valoraciones" },
  {
    $project: {
      _id: 0,
      curso: "$nombre",
      estudiante_id: "$valoraciones.estudiante_id",
      comentario: "$valoraciones.comentario",
      puntuacion: "$valoraciones.puntuacion",
      fecha: "$valoraciones.fecha"
    }
  }
]);

// Valoraciones hechas por el estudiante 1
db.cursos.aggregate([
  { $unwind: "$valoraciones" },
  { $match: { "valoraciones.estudiante_id": 1 } },
  {
    $project: {
      _id: 0,
      curso: "$nombre",
      comentario: "$valoraciones.comentario",
      puntuacion: "$valoraciones.puntuacion",
      fecha: "$valoraciones.fecha"
    }
  }
]);

// Valoraciones del estudiante 1 en sus cursos matriculados
db.estudiantes.aggregate([
  { $match: { estudiante_id: 1 } },
  { $unwind: "$cursos_matriculados" },
  {
    $lookup: {
      from: "cursos",
      localField: "cursos_matriculados",
      foreignField: "curso_id",
      as: "curso"
    }
  },
  { $unwind: "$curso" },
  { $unwind: "$curso.valoraciones" },
  {
    $match: {
      $expr: { $eq: ["$curso.valoraciones.estudiante_id", "$estudiante_id"] }
    }
  },
  {
    $project: {
      _id: 0,
      estudiante: "$nombre",
      curso: "$curso.nombre",
      comentario: "$curso.valoraciones.comentario",
      puntuacion: "$curso.valoraciones.puntuacion"
    }
  }
]);

// Consultas basicas
show collections;
db.estudiantes.find();
db.cursos.find();
