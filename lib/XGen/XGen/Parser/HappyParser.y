{

module XGen.Parser.HappyParser
( parse
)
where

import Data.Char
import Prelude   hiding (lex)
import XGen.Types
import XGen.Parser.Lexer
import XGen.Parser.ParseErrorMonad

}

%name parse
%tokentype { Character  }
%error     { parseError }
%monad { E } { thenE } { returnE }

%token
    lBracket                  { CLBracket   }
    rBracket                  { CRBracket   }
    hyphen                    { CHyphen     }
    question                  { CQuestion   }
    comma                     { CComma      }
    char                      { CChar $$    }

%%

xstring : tokens                            { XString (reverse $1)       }

tokens : token                              { [$1]                       }
       | tokens token                       { $2 : $1                    }

token : char                                { TLiteral $1                }
      | hyphen                              { TLiteral '-'               }
      | lBracket char rBracket              { (\c -> case c of
                                                     'v' -> TVowel
                                                     'c' -> TConsonant
                                                     'l' -> TLetter
                                                     'n' -> TNumber
                                                     _   -> TUnknown) $2 }
      | lBracket question rBracket          { TAny                      }
      | lBracket char hyphen char rBracket  { TRange $2 $4              }
      | lBracket listitems rBracket         { TList $2                  }
      
listitems : char comma char                 { [$1, $3]                  }
          | listitems comma char            { $1 ++ [$3]                }

{

-- parseError :: [Character] -> a
-- parseError _ = error "parse error"
-- parseError _ = Nothing
parseError tokens = failE "Parse error"
}
