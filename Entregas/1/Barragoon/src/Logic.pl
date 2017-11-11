%-------------------------------%
%-----------Game Logic----------%
%-------------------------------%

% -------------------------------------------------------------------------
% ----------------------------------- GAME  -------------------------------
% -------------------------------------------------------------------------

% --- Game Loop ---
startGamePvP:-
        initializeGamePvP(Game),
        playGame(Game).

initializeGamePvP(Game):-
        initialBoard(Board),
        Game = [Board, w, pvp], !.

playGame(Game) :-
        playerTurn(Game, UpdatedGame),
        switchPlayer(UpdatedGame, NextPlayerGame),
        playGame(NextPlayerGame).

playerTurn(Game, NewGame) :- 
        displayGame(Game),
        repeat,
        (
            chooseTile(RowSrc, ColSrc, 'Which tile would you like to move?')
        ),

        validateTile(Game, RowSrc, ColSrc),
        !,

        repeat,
        (
            choosePath(Path, 'Please insert the path that you want that piece to follow:\n(Use WASD - eg. wwwd + Enter).')
        ),

        validatePath(RowSrc, ColSrc, Path),
        !,

        /*validateMove() -> validate move acording to the rules.*/

        getBoard(Game, GameBoard),
        movePiece(Game,GameBoard, RowSrc, ColSrc, Path, NewGameBoard),

        setBoard(Game, NewGameBoard, NewGame).


% -------------------------------------------------------------------------
% ------------------------------ MOVEMENTS --------------------------------
% -------------------------------------------------------------------------

getDestCellFromPath(RowSrc, ColSrc, [], RowDest, ColDest):-
        RowDest = RowSrc,
        ColDest = ColSrc.
getDestCellFromPath(RowSrc, ColSrc, [Move|Tail], RowDest, ColDest) :-
        (
                Move == 'w' -> (RowDest1 is RowSrc-1, getDestCellFromPath(RowDest1,ColSrc,Tail,RowDest,ColDest));
                Move == 's' -> (RowDest1 is RowSrc+1, getDestCellFromPath(RowDest1,ColSrc,Tail,RowDest,ColDest));
                Move == 'a' -> (ColDest1 is ColSrc-1, getDestCellFromPath(RowSrc,ColDest1,Tail,RowDest,ColDest));
                Move == 'd' -> (ColDest1 is ColSrc+1, getDestCellFromPath(RowSrc,ColDest1,Tail,RowDest,ColDest))
        ).

% --- Move piece ---
movePiece(Game,GameBoard, RowSrc, ColSrc, Path, NewGameBoard) :-
        getDestCellFromPath(RowSrc, ColSrc, Path, RowDest, ColDest),
        isBarragoon(Game, RowDest, ColDest),
        moveFromSrcToDest(GameBoard,RowSrc,ColSrc,RowDest,ColDest,NewGameBoard).

moveFromSrcToDest(GameBoard, RowSrc, ColSrc, RowDest, ColDest, NewGameBoard) :-
        clearCell(GameBoard,  RowSrc,  ColSrc,  Value, NewGameBoard1),
        setCell(NewGameBoard1,RowDest, ColDest, Value, NewGameBoard).

% --- Check if it is a short move ---
%isShortMove(+Piece, +Path)
isShortMove(_Player-NDots, Path) :-
        length(Path, N),

        N1 is N-1,
        N1 == NDots.
        
% --- Check if it is a long move ---
%isLongMove(+Piece, +Path)
isLongMove(_Player-NDots, Path) :-
        length(Path, N),
        N == NDots.
        
% -------------------------------------------------------------------------
% ------------------------------ VALIDATIONS ------------------------------
% -------------------------------------------------------------------------

% --- Check if it is a valid tile ---
%validateTile(+Game, +RowSrcPos, +ColSrcPos): make sure the position corresponds to a piece of the player
validateTile(Game, RowSrc, ColSrc) :-

        getBoard(Game, Board),
        getCurrentPlayer(Game, CurrentPlayer),

        getCell(Board, RowSrc, ColSrc, Piece),
        
        Piece = CurrentPlayer-_.

validateTile(_Game, _RowSrc, _ColSrc) :-
        write('There\'s not a movable piece in that position.'), nl,
        write('Please, try another position.'), nl,
        fail. 
        %go_back to repeat cycle

% --- Check if it is a valid path ---
validatePathValues([]).
validatePathValues([H|T]) :- 
        member(H,['w','a','s','d']), 
        validatePathValues(T).

%validatePath(+Game, +RowSrcPos, +ColSrcPos, +Path): make sure the path is a valid one
validatePath(RowSrc, ColSrc, Path) :-
        %verify if it ends inside the board
        getDestCellFromPath(RowSrc, ColSrc, Path, RowDest, ColDest),
        RowDest < 9, RowDest >= 0,
        ColDest < 9, ColDest >= 0,
        
        %verify if it turns just once
        verifyTurnsOnce(Path).

validatePath(_, _, _) :-
        write('That path is not valid!'), nl,
        write('Please, try another path.'), nl,
        fail. 
        %go_back to repeat cycle

% --- Check if it turns just once ---
verifyTurnsOnce([H|T]) :-
        complementary(H,C),
        verifyTurnsOnceAux(T,H,0,C).

verifyTurnsOnceAux([],_,N,_):-
        N < 2.
verifyTurnsOnceAux([H|T], H, N, C) :-
        verifyTurnsOnceAux(T, H, N, C).
verifyTurnsOnceAux([H|T], Z, N, C) :-
        Z \= H,
        H \= C,

        complementary(H, C1),
        N1 is N+1,      
        verifyTurnsOnceAux(T, H, N1, C1).
        
% --- Check if it is a barragoon ---
isBarragoon(Game, Row, Col) :-

        getBoard(Game, Board),

        getCell(Board, Row, Col, Piece),
        ifelse(Piece==bg-'barraX', write('A barragoon was eaten in this move!'), write('No barragoons were eaten in this move!')).

% --- Check if movement is possible ---


% --- Valid coordinates ---
validColumns(['a','b','c','d','e','f','g','A','B','C','D','E','F','G']).

validRow(Y):- Y > 48, Y < 60.

complementary('w','s').
complementary('s','w').
complementary('a','d').
complementary('d','a').