; if (user != null) {
;     authenticate(user)
; } else {
;     reject()
; }
;
; when (status) {
;     Status.ACTIVE -> enable()
;     else -> disable()
; }

(if_expression
  . (_) @condition.expression
  . (control_structure_body (statements) @condition.consequence)
  . (control_structure_body (statements) @condition.alternative)?) @condition

(when_expression
  (when_subject)? @condition.subject
  (when_entry
    (when_condition) @condition.expression
    (control_structure_body) @condition.consequence)*
  (when_entry
    "else"
    (control_structure_body) @condition.alternative)?) @condition
