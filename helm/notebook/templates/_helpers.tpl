{{- define "notebook.name" -}}
notebook
{{- end }}

{{- define "notebook.fullname" -}}
{{ include "notebook.name" . }}
{{- end }}