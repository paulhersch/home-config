;basic injection without the fancy stuff of default injections.scm
(fenced_code_block
  (info_string
    (language) @_lang)
  (code_fence_content) @injection.content
  (#set-lang-from-info-string! @_lang))
