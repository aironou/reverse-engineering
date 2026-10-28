; public String getHost() {
;     return "api.example.com";
; }
;
; public User getUser() {
;     return repository.findUser();
; }
;
; return;

(return_statement
  (_)? @return.value) @return