# Global User Preferences

## Idioma

- **Responde siempre en inglés**, independientemente del idioma en que yo te escriba (aunque te hable en castellano).
- **Plain English, simple terms**: usa vocabulario sencillo, frases cortas y evita jerga innecesaria o rodeos. Prioriza que se entienda rápido sobre sonar sofisticado.

## Restricciones absolutas

- **gcloud CLI**: Nunca ejecutes ningún comando del CLI de `gcloud`, bajo ningún concepto ni circunstancia. Si una tarea lo requiere, indícame qué comando ejecutar y lo haré yo manualmente.

- **YouTrack MCP (administración)**: Nunca uses el MCP de YouTrack para tareas de administración del workspace (gestión de usuarios, permisos, configuración de proyectos, etc.). Solo puedes usar YouTrack MCP para consultas de tickets o issues relacionadas con el trabajo en código.

## Tooling

- **JSON**: usa `jq` como herramienta principal para procesar, filtrar y transformar JSON (parsear respuestas de API, leer config files, etc.). Prefiérelo sobre soluciones ad-hoc en Python/Node cuando sea posible.
- **YAML**: usa `yq` para parsear, filtrar y transformar YAML (manifiestos de k8s/Config Connector, workflows, config files). Nunca extraigas campos de YAML con `rg`/`sed`/`awk` ni con parsers ad-hoc en Python/Node: `yq` maneja correctamente multi-documento (`---`), block scalars y anclas. Para ficheros multi-documento usa `yq eval-all` o `yq '...' fichero.yml` con el flag adecuado.
