#include <iostream>
#include <stdlib.h>
#include <algorithm>
#include <vector>
using namespace std;

#define UNDEF -1
#define TRUE 1
#define FALSE 0

/* Este SAT Solver presenta la siguiente heuristica:
- Se puntua cada literal en función de las cláusulas en las que aparece.
- Si se encuentra un conflicto, se actualizan las puntuaciones de los literales en función de las cláusulas en las que aparecen.
- Cada TIME_UPDATE conflictos, se llama a rescale() multiplica todas las puntuaciones * 0.75 .
- Se escoge el literal con mayor puntuación para hacer la siguiente decisión.

DISCLAIMER: Las constantes MULT, TIME_UPDATE e INCREMENT son valores que se han obtenido tras realizar pruebas con distintos valores, aunque se podria hacer una mejor exploracion de estos.
*/


uint numVars;
uint numClauses;
vector<vector<int> > clauses;
vector<int> model;
vector<int> modelStack;
uint indexOfNextLitToPropagate;
uint decisionLevel;

uint conflictCnt;  
uint decisionCnt;

// VARIABLES AÑADIDAS

const double MULT = 0.75;     
const int TIME_UPDATE = 1000;
const int INCREMENT = 2;

vector<vector<int> > taulaAux;
vector<int> heuristic;
    

 void rescale() {
  for (uint i=1; i<=numVars; ++i) heuristic[i] *= MULT;
}

 void updateLiteralHeuristics(int index){
  vector<int> literalClause = clauses[index];
  int size = literalClause.size();

  for(int i = 0; i < size; ++i){
    int lit = literalClause[i];
    if(lit<0) heuristic[-lit] += INCREMENT;
    else heuristic[lit] += INCREMENT; 
  }
}


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
  taulaAux.resize(numVars*2+1);
  heuristic.resize(numVars+1,0.0);
  clauses.resize(numClauses);  
  // Read clauses
  for (uint i = 0; i < numClauses; ++i) {
    int lit;
    while (cin >> lit and lit != 0) {
        clauses[i].push_back(lit);
        if(lit < 0) {
          taulaAux[-lit+numVars].push_back(i);
          heuristic[-lit] += INCREMENT;
        }
        else {
          taulaAux[lit].push_back(i);
          heuristic[lit] += INCREMENT;
        }
    }
  }
}



 int currentValueInModel(int lit){
  if (lit >= 0) return model[lit];
  else {
    if (model[-lit] == UNDEF) return UNDEF;
    else return 1 - model[-lit];
  }
}


 void setLiteralToTrue(int lit){
  modelStack.push_back(lit);
  if (lit > 0) model[lit] = TRUE;
  else model[-lit] = FALSE;		
}

bool propagateGivesConflict ( ) {
  while ( indexOfNextLitToPropagate < modelStack.size() ) {
         
    int lit = modelStack[indexOfNextLitToPropagate];
    if (lit > 0) lit += numVars;
    else lit = -lit;
    
    ++indexOfNextLitToPropagate; 
    for (uint i = 0; i < taulaAux[lit].size(); ++i) {
        int literal_aux = taulaAux[lit][i]; 
      bool someLitTrue = false;
      int numUndefs = 0;
      int lastLitUndef = 0;
     
      for (uint k = 0; not someLitTrue and k < clauses[literal_aux].size(); ++k){
        int val = currentValueInModel(clauses[literal_aux][k]);
        if (val == TRUE) someLitTrue = true;
        else if (val == UNDEF){ 
          ++numUndefs; 
          lastLitUndef = clauses[literal_aux][k]; 
        }
      }


        if (not someLitTrue and numUndefs == 0) {
             ++conflictCnt;
             if(conflictCnt%TIME_UPDATE == 0) rescale();
             updateLiteralHeuristics(literal_aux);
            return 1; // conflict! all lits false
        }
        else if (not someLitTrue and numUndefs == 1) setLiteralToTrue(lastLitUndef);	
    }    
    // ++propagationCnt;
    }
  return 0;
}


 void backtrack(){
  uint i = modelStack.size() -1;
  int lit = 0;
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
}



// Heuristic for finding the next decision literal:
   int getNextDecisionLiteral(){
    int max_score = 0;
    int index_max = 0;
    for (uint i = 1; i <= numVars; ++i) {
      if (model[i] == UNDEF) {
          if(heuristic[i] > max_score){
            max_score = heuristic[i];
            index_max = i;
          }
      }
    }
    ++decisionCnt;
   return index_max; // returns 0 when all literals are defined
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
  model.resize(numVars+1,UNDEF);
  indexOfNextLitToPropagate = 0;  
  decisionLevel = 0;
  conflictCnt = 0; 
  decisionCnt = 0;
  
  // Take care of initial unit clauses, if any
  for (uint i = 0; i < numClauses; ++i)
    if (clauses[i].size() == 1) {
      int lit = clauses[i][0];
      int val = currentValueInModel(lit);
      if (val == FALSE) {cout << "UNSATISFIABLE" << endl; return 10;}
      else if (val == UNDEF) setLiteralToTrue(lit);
    }
  
  // DPLL algorithm
  while (true) {
    while ( propagateGivesConflict() ) {
      if ( decisionLevel == 0) { cout << "UNSATISFIABLE" << endl;  return 10; }
      backtrack();
    }
    int decisionLit = getNextDecisionLiteral();
    if (decisionLit == 0) { checkmodel(); cout << "SATISFIABLE" << endl;  return 20; }
    // start new decision level:
    modelStack.push_back(0);  // push mark indicating new DL
    ++indexOfNextLitToPropagate;
    ++decisionLevel; 
    setLiteralToTrue(decisionLit);    // now push decisionLit on top of the mark
  }
}
