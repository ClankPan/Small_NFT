/**
 * Module     : .mo
 * Copyright  : 
 * License    : 
 * Maintainer : 
 * Stability  : 
 */

//  公式ライブラリ読み込み
//  import <モジュール名>  "mo:base/<モジュール名>";
import HashMap "mo:base/HashMap";       //  NFTを管理する本体はハッシュマップを使用する．
import Principal "mo:base/Principal";   //  ICProtocolではaddressをPrincipal IDと呼称する．
import Nat "mo:base/Nat";               //  HashMapの第2引数で使用
import Hash "mo:base/Hash";             //  HashMapの第3引数で使用
import Iter "mo:base/Iter";             //  preupgrade,postupgradeで使う．HashMapのエントリを書き出す．

import Result "mo:base/Result";         //  エラー処理用のモジュール（add:by hokosugi）              


//  `shared(<変数名>)`を加えることで，ICProtocolからこのトランザクションの呼び出し人を受け取ることができる．
//  `<変数名>.caller`でそのPrincipalを参照できる．
//  引数は　`<変数名> : <型>`で指定．
//  class名はアッパーキャメル記法
//  変数名はローウワーキャメル記法
shared(installer) actor class Small_NFT() {

    /*  actor classの初期化
    motokoのclassにはconstractorは存在せず，ベタ書きで初期化をしていく．

    NFTの場合，下記を定義する．
        ① 型
        ② upgrade用のエントリ
            - HashMapなどの高階変数はstable修飾子をつけることができないため，
            　upgrade時には，system func pregrade/postgradeを使って明示的に保存する必要がある．
        ③ 本体の変数
    */
    
    //① 型
    public type TokenID = Nat;
    public type Attribute = {
        key: Text;
        value: Text;
    };
    public type TokenMetadata = {
        attributes: ?[Attribute];
    };
    public type TokenInfo = {
        minter : Principal;
        var owner : Principal;  //  書き換え可能な変数型として定義
        var metadata : ?TokenMetadata;
    };

    //② エントリ　高階変数のupgrade用のエントリ　
    private stable var _tokenRegistryEntries : [(TokenID, TokenInfo)] = [];

    //③ 変数本体
    //  第1引数：テーブル数(?)，第2引数：keyの比較関数，第3引数：keyのhash化関数
    //  privateな変数にはアンダースコアをつける風習らしい？
    private var _tokenRegistry = HashMap.HashMap<TokenID, TokenInfo>(1, Nat.equal, Hash.hash);
    private stable var _latestTokenID: Nat = 0;

    //④ エラー処理(add: by hokosugi)
    //  Resultライブラリから型指定(https://smartcontracts.org/docs/base-libraries/Result.html)
    public type Errors = {
        #notFoundTokenInfo;
        #alreadyExist;              // 未使用
    };
    // okの時で関数内で別の型がある時に使う
    public type Okays = {
        #canTransfer : Text;
        #IsSuccess : Nat;
    };
    

    public shared(msg) func mint(to : Principal, metadata : ?TokenMetadata) : async TokenID{
        //  最新のtokeIDの更新
        _latestTokenID += 1;

        //  tokenInfoの作成
        let token : TokenInfo = {
            minter = msg.caller;
            var owner = to;
            var metadata = metadata;
        };

        //  HashMapへ追加
        _tokenRegistry.put(_latestTokenID, token);

        return _latestTokenID;
    };


    public query func ownerOf(tokenId : TokenID) : async Result.Result<Text, Errors> {   //public funcの戻り値はasync型として記述
        //  このswitch-case文がmotokoの鬼門
        /*
        HashMapはnull許容型として帰ってくるため，型安全性のため一度Nullを場合分けしなくてはならない．
        switchの条件式内でHashMapを参照して，caseで受ける．
        case内では，?<変数名>としてoptionTypeの変数で受けると，case(_)の方へNullが行く．
        hashmapが入れ子の場合，valueを取り出すたびにこのswitch-caseをネストしなければならない（驚愕）
        */
        switch(_tokenRegistry.get(tokenId)) {
            case(?tokenInfo) {
                //owner
                return #ok(Principal.toText(tokenInfo.owner));
            };
            case(_){
                return #err(#notFoundTokenInfo);
            };
        };  
    };

    public shared(msg) func transfer(to : Principal, tokenId : TokenID) : async Result.Result<Okays, Errors> {
        switch(_tokenRegistry.get(tokenId)) {
            case(?tokenInfo) {
                if(tokenInfo.owner != msg.caller ) {
                    return #ok(#canTransfer("yes"));
                };

                //ownerの書き換え
                tokenInfo.owner := to; // switch-caseは参照渡しなので，これで直接代入できるはず．
                return #ok(#IsSuccess(tokenId));
            };
            case(_){
                return #err(#notFoundTokenInfo);
            };
        };
    };

    public query func latestTokenID() : async Result.Result<Nat, Text> {
        return  #ok(_latestTokenID);
    };

    //State functions
    /*
    これを記述しないと，stable修飾子で限定した変数以外のデータは，upgrade（コードのアップデート）時に全て失われる．
    高階変数にはstable修飾子をつけることができないので，
    NFT本体を保持する_tokenRegistryは下記の関数を使って明示的に保存する必要がある．

    実際どうやるのかは後でかく．
    */
    system func preupgrade() {
        _tokenRegistryEntries := Iter.toArray(_tokenRegistry.entries());
    };
    system func postupgrade() { //  保存したエントリをもとに復元
        _tokenRegistry := HashMap.fromIter<TokenID, TokenInfo>(_tokenRegistryEntries.vals(), 1, Nat.equal, Hash.hash);
        _tokenRegistryEntries := [];
    };

};
