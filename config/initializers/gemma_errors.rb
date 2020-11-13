module Gemma
  class SystemError          < RuntimeError; end
  class MismatchOrganization < RuntimeError; end
  class WrongCredentials     < RuntimeError; end
  class InsufficientRights   < RuntimeError; end
  class MismatchThing        < RuntimeError; end
  class NegativeDeposit      < RuntimeError
    def to_s 
      "Controllare che alla data selezionata siano presenti sufficienti oggetti o che l'operazione richiesta non renda impossibili alcune operazioni già effettuate."
    end
  end
  class UnsupportedOperation < RuntimeError; end
  class NoLocation           < RuntimeError; end
  # Durcs
  class UnsupportedFileType  < RuntimeError; end
  class ExcessiveUploadSize  < RuntimeError; end
  # DsaSerarch
  class NoUser               < RuntimeError
    def to_s
      "Non esiste l'utente selezionato nel database di Ateneo. Si prega di fare la ricerca con 'cerca utente'"
    end
  end
  class TooManyUsers         < RuntimeError
    def to_s
      "Sono presenti troppi utenti nel database di Ateneo che soddisfano i parametri di ricerca. Si prega di raffinare la ricerca"
    end
  end
end

