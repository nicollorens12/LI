#include <iostream>
#include <stdlib.h>
#include <algorithm>
#include <vector>
using namespace std;

#define UNDEF -1
#define TRUE 1
#define FALSE 0

uint numVars;
uint numClauses;
vector<vector<int> > clauses;
vector<int> model;
vector<int> modelStack;
uint indexOfNextLitToPropagate;
uint decisionLevel; // nombre de decisions fetes

// * NOTA IMPORTANTE: Distinguimos entre variables (que pueden ser negadas o no) y literales, que son valores concretos de las variables.

// * NOTA IMPORTANTE: Para ejecutar, hacer "make misat" (es NECESARIO usar el Makefile ya que compilar con el flag -03, NECESARIO para un 
//                    rendimiento eficiente del SAT solver), luego ejecutar el script usando "bash scriptKisSAT.sh" para comparar con kissat.

// ********** VARIABLES AÑADIDAS **********
// En cada posicion i hay una lista con las cláusulas en las que aparece el literal i (no negado):
vector<vector<int> > ocurrencias;
// En cada posicion i hay una lista con las cláusulas en las que aparece el literal i negado:
vector<vector<int> > ocurrenciasNegadas;
// Cada variable tiene un score asignado en función del número de ocurrencias que tiene en conflictos:
vector<double> varScore;
// Contador de conflictos que se han encontrado resolviendo el problema SAT:
int conflictCounter = 0;
// Esta constante determina cada cuantos conflictos se dividen los scores por 2, para dar mas importancia a los conflictos recientes.
const int N = 1000;


// ********** FUNCION  MODIFICADA **********
// ---> Ahora a medida que se  leen las clausulas vamos llenando las listas de cláusulas en
//      que aparece cada literal.
void readClauses( ){

  // Skip comments
  char c = cin.get();
  while (c == 'c') {
    while (c != '\n') c = cin.get();
    c = cin.get();
  }

  // Read "cnf numVars numClauses"
  string aux;
  cin >> aux >> numVars >> numClauses;
  clauses.resize(numClauses);
  // // +1 para permitir la indexación desde 1:
  ocurrencias.resize(numVars + 1);
  ocurrenciasNegadas.resize(numVars + 1);
  // Inicializa las puntuaciones de las variables:
  varScore.resize(numVars + 1, 0.0);

  // Read clauses
  for (uint i = 0; i < numClauses; ++i) {
    int lit;
      while (cin >> lit and lit != 0) {
          clauses[i].push_back(lit);
          // Vamos llenando las listas de ocurrencias:
          // Si el literal es negativo, se agrega el índice de la cláusula a la lista de ocurrencias del literal negado
          if (lit < 0) ocurrenciasNegadas[-lit].push_back(i);
          // Si el literal es positivo, se agrega el índice de la cláusula a la lista de ocurrencias del literal positivo
          else ocurrencias[lit].push_back(i);
      }
  }
}


int currentValueInModel(int lit){
  // Si la variable no está negada, el valor es el que es:
  if (lit >= 0) return model[lit];
  // Sino
  else {
    // Si está indefinida, hay que devolver eso
    if (model[-lit] == UNDEF) return UNDEF;
    // Si no está indefinida, hay que devolver el negado
    else return 1 - model[-lit];
  }
}

// Pone el valor de una variable a cierto:
void setLiteralToTrue(int lit){
  modelStack.push_back(lit);
  if (lit > 0) model[lit] = TRUE;
  else model[-lit] = FALSE;
}

// ********** FUNCION  MODIFICADA **********
// ---> Antes el bucle recorría cada vez todas las cláusulas en busca de conflicto.
//      Ahora, solo propaga el nextLiteralToPropagate
bool propagateGivesConflict ( ) {
  // Cuando esto deja de ser cierto, quiere decir que no quedan literales por propagar:
  while ( indexOfNextLitToPropagate < modelStack.size() ) {
    // Tomamos el siguiente literal a propagar:
    int lit = modelStack[indexOfNextLitToPropagate];
    // En función del literal está negado o no, tomaremos su lista de cláusulas en las que
    // aparece con el valor contrario, ya que son las que generarán potenciales conflictos:
    vector<int>& occur = lit > 0 ? ocurrenciasNegadas[lit] : ocurrencias[-lit];
    // Itera las clausulas de la lista de ocurrencias seleccionada:
    for (int i : occur) {
      bool someLitTrue = false;
      int numUndefs = 0;
      int lastLitUndef = 0;
      // Itera las variables
      for (uint k = 0; not someLitTrue and k < clauses[i].size(); ++k){
        int val = currentValueInModel(clauses[i][k]);
        if (val == TRUE) someLitTrue = true;
        else if (val == UNDEF){ ++numUndefs; lastLitUndef = clauses[i][k]; }
      }
      // Si no tenemos ninguna variable cierta y ya no quedan variables por definir... CONFLICTO!!!
      if (not someLitTrue and numUndefs == 0) {
        for (int k = 0; k < clauses[i].size(); ++k){
          int var = abs(clauses[i][k]);
          // Se incrementa la puntuación de la variable ya que ha aparecido en un conflicto:
          varScore[var] += 1.0;
        }
        // Devolvemos cierto porque todos los literales de una clausula han resultado ser falsos, es decir, hay conflicto:
        return true;
      }
      // Sino si queda alguno por definir, ese tendra que ser cierto:
      else if (not someLitTrue and numUndefs == 1) setLiteralToTrue(lastLitUndef);
    }
    // Incrementamos el "puntero" en la pila al siguiente literal a propagar:
    ++indexOfNextLitToPropagate;
  }
  return false;
}

void updateScoresOnConflict() {
    ++conflictCounter;
    if (conflictCounter >= N) {
        for (double& score : varScore) {
            score /= 2.0;
        }
        conflictCounter = 0;
    }
}

// ********** FUNCION  MODIFICADA **********
// ---> Se ha añadido una linea al final de la funcion para actualizar los scores (si es necesario) cuando hay un conflicto.
void backtrack(){
  uint i = modelStack.size() -1;
  int lit = 0;
  // Este bucle itera en busca de la última decisión tomada
  while (modelStack[i] != 0){ // 0 is the DL mark

    lit = modelStack[i];
    model[abs(lit)] = UNDEF;
    modelStack.pop_back();
    --i;
  }
  // at this point, lit is the last decision
  modelStack.pop_back(); // remove the DL mark
  --decisionLevel;
  indexOfNextLitToPropagate = modelStack.size();
  setLiteralToTrue(-lit);  // reverse last decision

  // Llama a updateScoresOnConflict cada vez que se revierte una decisión:
  updateScoresOnConflict();
}


// ********** FUNCION  MODIFICADA **********
// ---> Ahora se selcciona el literal con mejor heurística, es decir, con mejor score.
int getNextDecisionLiteral() {
    double maxScore = -1.0;
    int bestVar = 0;
    for (uint i = 1; i <= numVars; ++i) {
        if (model[i] == UNDEF && varScore[i] > maxScore) {
            maxScore = varScore[i];
            bestVar = i;
        }
    }
    return bestVar;
}

void checkmodel(){
  for (uint i = 0; i < numClauses; ++i){
    bool someTrue = false;
    for (uint j = 0; not someTrue and j < clauses[i].size(); ++j)
      someTrue = (currentValueInModel(clauses[i][j]) == TRUE);
    if (not someTrue) {
      cout << "Error in model, clause is not satisfied:";
      for (uint j = 0; j < clauses[i].size(); ++j) cout << clauses[i][j] << " ";
      cout << endl;
      exit(1);
    }
  }
}

int main(){

  readClauses(); // reads numVars, numClauses and clauses
  model.resize(numVars+1,UNDEF); // Se suma 1 para poder usar variables de 1 a numVars, el 0 se deja sin utilizar
  indexOfNextLitToPropagate = 0;
  decisionLevel = 0;
  
  // Take care of initial unit clauses, if any
  for (uint i = 0; i < numClauses; ++i)
    if (clauses[i].size() == 1) {
      int lit = clauses[i][0];
      int val = currentValueInModel(lit); // Consulta el valor de la variable
      if (val == FALSE) {cout << "UNSATISFIABLE" << endl; return 10;}
      else if (val == UNDEF) setLiteralToTrue(lit);
    }
  
  // DPLL algorithm
  while (true) {
    // Se mira si hay conflicto
    while ( propagateGivesConflict() ) {
      if ( decisionLevel == 0) { cout << "UNSATISFIABLE" << endl; return 10; }
      // Si hay conflicto, se revierte la última decisión
      backtrack();
    }
    // Se escoge un literal sobre el que decidir
    int decisionLit = getNextDecisionLiteral();
    if (decisionLit == 0) { checkmodel(); cout << "SATISFIABLE" << endl; return 20; }
    // start new decision level:
    modelStack.push_back(0);  // push mark indicating new DL (antes de cada literal decidido se coloca un 0 ya que no podemos tener números de color rojo como en las diapositivas)
    ++indexOfNextLitToPropagate;
    ++decisionLevel;
    setLiteralToTrue(decisionLit);    // now push decisionLit on top of the mark
  }
}
