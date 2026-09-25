{{- define "notebook.name" -}}
notebook
{{- end }}

{{- define "notebook.fullname" -}}
{{ include "notebook.name" . }}
{{- end }}

{{- define "notebook.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
    {{- default (include "notebook.fullname" .) .Values.serviceAccount.name }}
{{- else }}
    {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "notebook.labels" -}}
app.kubernetes.io/name: notebook
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}