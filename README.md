# AgileSchemaEvolver
A data model-independent tooling aimed to the agile schema evolution of NoSQL and relational databases, which is based on the U-Schema unified generic metamodel (Project PID2020-117391GB-I00, Ministerio de Ciencia, Innovación y Universidades, España)

# Proyect

This repository includes the main results achieved in the project proyecto **"An agile approach to evolve NoSQL and Relational schemas: data and code migration"**, project PID2020-117391GB-I00, (september, 2021 to february,2025) found by the Spanish Ministry of Science and Universities, que llevó a cabo el grupo Modelum de la Universidad de Murcia, cuyo IP es Jesús J. García Molina.

This project has developed an innovative toolset to support agile and safe database evolution, addressing current needs in continuous software delivery and adaptive systems. Traditional database systems often lack flexibility when adapting to evolving application requirements. Our approach enables systematic and controlled schema changes across a range of database technologies, both relational and NoSQL.
     At the core of the solution is U-Schema, a unified metamodel that abstracts and represents database schemas independently of the underlying technology. Based on this model, we have designed two domain-specific languages: Athena for schema definition, and Orion for expressing evolution scripts through a formal taxonomy of schema changes. This taxonomy is one of the project’s main theoretical contributions and has been designed to be independent of any specific data model, making it applicable across diverse database paradigms.
     The tools support schema versioning and automated migration, generating native scripts for widely used database systems such as MongoDB, Cassandra, Neo4j, and MySQL. While automatic rollback is not implemented, the system maintains a complete history of evolution scripts, enabling the recreation of any past schema version when needed.
     Additionally, we have developed mechanisms for static code analysis (based on CodeQL) that detect application code fragments potentially affected by schema changes—such as JPQL queries or JPA annotations—and report issues using standard formats. These analyses are integrated in CI/CD pipelines through GitHub Actions, helping teams detect and address potential failures early in the development process.
     The approach has been validated through real-world datasets and case studies, resulting in international publications, open-source prototypes, and academic contributions. Overall, the project advances the capabilities available for database evolution in modern application development environments.
     Recently, we have also started to explore the use of Large Language Models (LLMs) to assist in the generation of Athena schemas and Orion evolution scripts from natural language descriptions, opening new opportunities for future research and tooling.




que demuestra cómo realizar una integración continua con una herramienta predictora mediante el lenguaje Orion. También se proporciona 
un genererador de Orion a MySQL encargado de las migraciones de esquema.





# Mi proyecto

- 📁 **.github**
  - 📁 codeql
  - 📄 codeql-config.yml
  - 📁 workflows
    - 📄 codeql-analysis.yml
    - 📄 migration-schema.yml
    - 📄 upload-sarif.yml
- 📁 **orion**
  - 📁 orion_scripts
  - 📄 version_table.md
  - 📄 orion_schema_version.txt
- 📁 **Tools**
  - 📁 es.um.uschema.xtext.athena.parent
  - 📁 es.um.uschema.xtext.orion.parent
  - 📁 spring.data.jpa.codeq.generator
  - 📁 uschema
- 📁 **Publications**
  - 📄 Comonos-2023.pdf
  - 📄 IEEE-TDKE-2024.pdf
  - 📄 Thesis-Orion-2023-AlbertoHC.pdf
  - 📄 Thesis-Uschema-2023-CarlosFC.pdf
  - 📄 TFG-OrionFlow-2025-AntonioPS.pdf

# Componentes principales

1. **Integración continua** (`.github/workflows/`)  
   - `migration-schema.yml`: gestion de la tabla de versiones
   - `codeql-analysis.yml`: genera AST de Java y analiza con CodeQL  
   - `upload-sarif.yml`: sube resultados SARIF a code-scanning  

2. **Migraciones Orion** (`orion/`)  
   - `orion_scripts/`: scripts de migración nombrados `V{n}_{descripción}.orion`  
   - `orion_schema_version.txt`: controla la última versión aplicada  
   - `version_table.md`: tabla de versiones según convención Flyway  

3. **Herramientas M2T** (`tools/`)  
   - **Athena & Orion** (Xtext): DSLs para esquema prescriptivo y operaciones  
   - **CodeQL Generator**: convierte Orion → JPQL/@Query anotadas → consultas CodeQL  
   - **U-Schema**: metamodelo unificado relacional/NoSQL  

4. **Caso de uso** (`UseCase/`)  
   - Aplicación sencilla de ejemplo en Java/Spring Boot con Spring Data JPA

# Como ejecutar herramienta M2T a MySQL

1. Se debe instalar desde la página oficial de eclipse el paquete modeling tools: [Modeling Tools](https://www.eclipse.org/downloads/packages/release/2024-12/r/eclipse-modeling-tools) 

2. Una vez instalado, se deben instalar las siguientes dependencias desde eclipse marketplace:
   - [Xtext](https://marketplace.eclipse.org/content/xtext)
   - [maven2ecore](https://download.eclipse.org/technology/m2e/releases/2.8.0) Esta versión se debe instalar desde install new software, ya que no está disponible en el marketplace.

3. Importar los siguientes proyectos:
   - `es.um.uschema.xtext.orion.parent` 
   - `es.um.uschema.xtext.athena.parent`
   - `uschema`

4. Una vez importados, para los proyectos Xtext de Athena y Orion, se debe acceder al paquete con el mismo nombre del proyecto y ejecutar el archivo **Generate(Athena|Orion).mwe2**. El paso se procederá a realizar con errores, el código se construirá y se generarán los archivos necesarios para la herramienta. Se deben compilar ambos, primero el de Athena y luego el de Orion.

5. Una vez instalado, el método de entrada se encuentra dentro del proyecto `es.um.uschema.xtext.orion`:
   - `src/main/java/es/um/uschema/xtext/orion/Orion2MySQLMain.java`

6. En los argumentos se especifica el fichero de entrada y de salida en los argumentos:
   ```java
   val customArgs = newArrayList("-i", "models/sql/Umugram.orion", "-o", "models/sql/code-generated")
   ```

# Como ejecutar workflows junto con Orion

1. Se debe crear un fichero orion y colocarlo en la raiz del repositorio, por ejemplo `Umugram.orion`.
   ```txt
   ADD ENTITY User {
      +id: Long,
      name: String,
      !email: String
   }
   ```
2. Se debe de subir el fichero mostrando en el commit la cabecera de mensaje con el nombre idéntico al del fichero orion, por ejemplo `Umugram`. Es decir:
   ```bash
   git add Umugram.orion
   git commit -m "Umugram.orion"
   git push origin main
   ```
3. Una vez subido, los cambios apareceran minutos después en la sección de Github > Security > Code Scanning, donde se podrá ver el resultado de la ejecución del workflow `codeql-analysis.yml`.

4. Para tomar una decisión, existen dos mensajes posibles tras este paso. La cabecera debe de ser vacia (--allow-empty):
- orion(accept): nombre_fichero.orion, descripcion
- orion(cancel): nombre_fichero.orion

5. Envio de los casos: 
- Caso de aceptación. 
   ```bash
   git add Umugram.orion
   git commit --allow-empty "orion(accept): Umugram.orion, descripcion"
   git push origin main
   ```
- Caso de cancelación.
   ```bash
   git add Umugram.orion
   git commit --allow-empty "orion(cancel): Umugram.orion"
   git push origin main
   ```

# Authors

- [@Zerep0](https://www.github.com/Zerep0)



