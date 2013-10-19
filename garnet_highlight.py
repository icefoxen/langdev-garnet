from pygments.lexer import RegexLexer
from pygments.token import *

class GarnetLexer(RegexLexer):
   name = 'Garnet'
   aliases = ['garnet']
   filenames = ['*.gt']

   tokens = {
      'root' : [
         (r'def', Keyword)
      ]
   }

class DiffLexer(RegexLexer):
    name = 'Diff'
    aliases = ['diff']
    filenames = ['*.diff']

    tokens = {
        'root': [
            (r' .*\n', Text),
            (r'\+.*\n', Generic.Inserted),
            (r'-.*\n', Generic.Deleted),
            (r'@.*\n', Generic.Subheading),
            (r'Index.*\n', Generic.Heading),
            (r'=.*\n', Generic.Heading),
            (r'.*\n', Text),
        ]
    }
   
def setup(app):
    pass
    #app.add_lexer('garnet', DiffLexer)
    #app.add_lexer('garnet', GarnetLexer)




