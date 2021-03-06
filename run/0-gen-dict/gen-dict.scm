#! /usr/bin/env guile
!#
;
; gen-dict.scm - Generate a random artificial grammar
;
; The generated dictionary is determined by the parameters in this file.
;
(use-modules (opencog) (opencog nlp fake))

; Number of Link Grammar link types (connector types)
(define num-link-types 6)

; Link-type Zipf distribution exponent. The generated random grammar
; will use different link types with a Zipfian distribution, with this
; exponent. Setting this to 1 gives the classic Zipf distribution, with
; link type "A" being more likely than "B" which is more likely than "C"
; and so on. Setting this to zero gives a uniform random distribution.
(define link-type-exp 1)

; Maximum size of disjuncts; that is, the maximum number of connectors
; in a disjunct. Randomly-created disjuncts will have 1 to this many
; connectors in them. The size distribution is Zipfian, controlled by
; the exponent `disjunct-exp`.
(define max-disjunct-size 3)

; Disjunct-size Zipf distribution exponent. The generated random
; disjunct will be of varying length, with the length following a
; Zipfian distribution. Setting this to 1 gives the classic Zipf
; distribution, so that most disjuncts will be of size 1, a few will
; be size 2, fewer still of size 3, etc. Setting this to zero gives
; a uniform distribution. Setting this negative will make most disjuncts
; have the `max-disjunct-size`.
(define disjunct-exp 0.5)

; Disjuncts per section. Each section will contain up to this many
; different disjuncts. The number of disjuncts per section follows a
; Zipfian distribution, with an exponent of `section-exp`.
(define section-size 20)

; Section-size Zipf distribution exponent. The generated random section
; will have a varying number of disjuncts in it, with the number
; following a Zipfian distribution. Setting this to 1 gives the classic
; Zipf distribution, so that most sections will be have only 1 disjunct
; in them; a few will be size 2, fewer still of size 3, etc. Setting
; this to zero gives a uniform size distribution. Setting this negative
; will make most sections have `section-size` disjuncts in them.
(define section-exp 0.0)

; Number of pos tags
(define num-pos 10)

; Number of grammatical classes
(define num-classes 10)

; Number of pos tags per class
(define class-size 8)

; Exponent of the class-size distribution.
; Setting this to 1.0 gives the classic Zipf distribution;
; setting it to 0.0 gives the uniform distribution.
; Using Zipf means that in most cases, each word class will have only
; one or two pos-tags in it; setting it to uniform means that larger
; classes (largr complexity) will be common. Setting the exponent
; negative will make most classes to be maximal in size, i.e. to have
; to have `class-size` elements.
(define class-exp -0.1)

; Number of synonyms in a word-class
(define num-synonyms 6)

; Exponent of the synonym word-class size distribution.
; Setting this to 1.0 gives the classic Zipf distribution;
; setting it to 0.0 gives the uniform distribution.
; Using Zipf means that in most cases, there will be only one or
; two synonyms; setting it to uniform means that large synonym classes
; will be common. Setting the exponent negative will make most
; synonym clases have the max allowed, i.e. to have `num-synonyms`
; in each one.
(define synonym-exp 0.5)

; Fraction of words that may have multiple word-senses.
; Must be floating point between zero and one.
(define sense-frac 0.3)

; XXX FIXME: The LG dictionary complains about multiply defined words.
; We should modify LG to either allow this, or we should change the
; code here to not do this.
(define sense-frac 0.0)

; Maximum number of distinct word-senses each word may have.
; The actual number of word senses generated will follow a Zipfian
; distribution, with exponent `sense-exp`.
(define num-senses 3)
(define sense-exp 0.5)


; Output file
(define dict-file "/tmp/4.0.dict")

; -------------------------------------------
; Generators for each of the different parts of the grammar.

(define secgen
	(make-section-generator
		num-link-types
		max-disjunct-size
		section-size
		link-type-exp
		disjunct-exp
		section-exp))

(define posgen
	(make-pos-generator
		num-pos
		secgen))

(define classgen
	(make-class-generator
		num-classes
		num-pos
		class-size
		class-exp))

(define wordgen
	(make-word-generator
		num-classes
		num-synonyms
		synonym-exp))

(define sensegen
	(make-sense-generator
		sense-frac
		num-classes
		num-senses
		sense-exp))

(define port (open-file dict-file "w"))

(format port "%\n% Randomly generated dictionary\n%\n")
(format port "% Version: 0.1\n")
(format port "% Num link types: ~A\n" num-link-types)
(format port "% Link type exponent: ~A\n" link-type-exp)
(format port "% Disjunct size: ~A\n" max-disjunct-size)
(format port "% Disjunct exponent: ~A\n" disjunct-exp)
(format port "% Section size: ~A\n" section-size)
(format port "% Number of POS: ~A\n" num-pos)
(format port "% Number of classes:  ~A\n" num-classes)
(format port "% Class size: ~A\n" class-size)
(format port "% Class exp: ~A\n" class-exp)
(format port "% Number of synonyms:  ~A\n" num-synonyms)
(format port "% Synonym exponent: ~A\n" synonym-exp)
(format port "% Word-sense fraction: ~A\n" sense-frac)
(format port "% Number of word-senses: ~A\n" num-senses)
(format port "% Word-sense exponent: ~A\n" sense-exp)
(format port "%\n")

(format port "#define dictionary-version-number 5.9.0;\n")
(format port "#define dictionary-locale C;\n")
(print-LG-flat port (posgen))
(print-LG-flat port (classgen))
(print-LG-flat port (wordgen))
(print-LG-flat port (sensegen))

(format port "<UNKNOWN-WORD>:  XXXXXX+;\n")
(close port)
(exit)
