README.md:
	emacs --script $$HOME/Code/make-readme-markdown/make-readme-markdown.el < omni-jump.el > README.md

clean:
	rm README.md
