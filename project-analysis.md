# ZK Panagram プロジェクト分析レポート

## 概要
このプロジェクトは、ゼロ知識証明（ZK）を使用したブロックチェーン上のパナグラム（アナグラム）推理ゲームです。ユーザーは秘密の単語を推測し、正解すると証明なしに正解を知っていることを証明してNFTを獲得できます。

## プロジェクト構成

### 1. circuits/ - ゼロ知識証明回路
**技術スタック**: Noir (Aztec製ZK言語)

#### ファイル構成
- `Nargo.toml` - Noirプロジェクトの設定ファイル
- `src/main.nr` - ZK回路のメインロジック
- `target/` - コンパイル済み回路ファイル

#### 主要機能
```noir
fn main(guess_hash: Field, answer_double_hash: pub Field, address: pub Field) {
    let addr_pow = address.pow_32(2);
    let guess_hash_decomposed: [u8; 32] = guess_hash.to_be_bytes();
    let guess_double_hash_decomposed: [u8; 32] = keccak256::keccak256(guess_hash_decomposed, 32);
    
    assert(addr_pow == address.pow_32(2));
    assert(Field::from_be_bytes(guess_double_hash_decomposed) == answer_double_hash);
}
```

**回路の仕組み:**
1. **プライベート入力**: `guess_hash` (推測のハッシュ)
2. **パブリック入力**: `answer_double_hash` (正解のダブルハッシュ), `address` (ユーザーアドレス)
3. **検証プロセス**: 
   - 推測をkeccak256でハッシュ化
   - 結果が正解のダブルハッシュと一致するかチェック
   - アドレスの検証（フロントランニング対策）

#### 依存関係
- `keccak256` - ハッシュ化ライブラリ（Noir-lang製）

---

### 2. contracts/ - スマートコントラクト
**技術スタック**: Solidity 0.8.24, Foundry, OpenZeppelin

#### ファイル構成
- `src/Panagram.sol` - メインゲームコントラクト
- `src/Verifier.sol` - ZK証明検証コントラクト（自動生成）
- `src/metadata/` - NFTメタデータ（JSON）
- `test/Panagram.t.sol` - Foundryテストファイル
- `js-scripts/generateProof.ts` - 証明生成スクリプト

#### 主要機能

##### Panagram.sol
```solidity
contract Panagram is ERC1155, Ownable {
    IVerifier public s_verifier;
    uint256 public s_currentRound;
    address public s_currentRoundWinner;
    mapping(address => uint256) public s_winnerWins;
    bytes32 public s_answer;
    uint256 public MIN_DURATION = 10800; // 3時間
}
```

**核心機能:**
1. **ラウンド管理**: `newRound()` - 新しいゲームラウンドを開始
2. **推測システム**: `makeGuess()` - ZK証明を使用した推測提出
3. **NFT発行**: 
   - 最初の正解者: NFT ID 0（ゴールド）
   - 二番目以降の正解者: NFT ID 1（シルバー）
4. **セキュリティ**: 
   - 最小期間制限（3時間）
   - 同一ラウンドでの重複回答防止
   - フロントランニング対策

##### イベント・エラーハンドリング
```solidity
event Panagram__RoundStarted();
event Panagram__NFTMinted(address winner, uint256 tokenId);
error Panagram__IncorrectGuess();
error Panagram__AlreadyAnsweredCorrectly();
```

#### テストカバレッジ
- 正解推測テスト
- 新ラウンド開始テスト
- 不正解推測テスト
- 複数回答者テスト

---

### 3. src/ - フロントエンド
**技術スタック**: React, TypeScript, Vite, Wagmi, TailwindCSS

#### ファイル構成
- `App.tsx` - アプリケーションルート
- `components/` - Reactコンポーネント
- `utils/generateProof.ts` - 証明生成ユーティリティ
- `abi/abi.ts` - コントラクトABI定義
- `config.ts` - Wagmi設定
- `constant.ts` - 定数定義

#### 主要コンポーネント

##### Panagram.tsx - メインゲームUI
```tsx
function Panagram() {
  const { isConnected, address: userAddress } = useAccount();
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-br from-purple-500 via-pink-500 to-red-500">
      <ConnectWallet />
      {isConnected && (
        <div className="flex flex-col lg:flex-row gap-8">
          <div className="w-full lg:w-1/2">
            <PanagramImage />
            <Input />
          </div>
          <div className="w-full lg:w-1/2">
            <NFTGalleryContainer userAddress={userAddress} />
          </div>
        </div>
      )}
    </div>
  );
}
```

##### Input.tsx - 推測入力・証明生成
```tsx
const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
  // 1. 推測文字列をハッシュ化
  const guessHex = keccak256(toUtf8Bytes(guessInput));
  
  // 2. Field modulusで削減
  const reducedGuess = BigInt(guessHex) % FIELD_MODULUS;
  
  // 3. 証明生成
  const { proof } = await generateProof(guessHash, address, showLog);
  
  // 4. スマートコントラクト呼び出し
  await writeContract({
    address: PANAGRAM_CONTRACT_ADDRESS,
    abi: abi,
    functionName: "makeGuess",
    args: [`0x${uint8ArrayToHex(proof)}`],
  });
};
```

#### Web3統合
- **Wagmi**: Ethereum接続管理
- **チェーン対応**: Sepolia, Tenderly Virtual Mainnet
- **ウォレット対応**: MetaMask, WalletConnect, Safe

---

## 技術アーキテクチャ

### ZK証明フロー
1. **フロントエンド**: ユーザーが推測を入力
2. **証明生成**: Noir回路で推測を検証する証明を生成
3. **スマートコントラクト**: HonkVerifierで証明を検証
4. **NFT発行**: 検証成功時にERC1155 NFTを発行

### セキュリティ対策
1. **フロントランニング防止**: アドレスを回路に含める
2. **重複回答防止**: ラウンド別回答履歴管理
3. **時間制限**: 最小ラウンド期間（3時間）
4. **オーナー制御**: ラウンド開始権限制御

### パフォーマンス最適化
1. **Field Modulus**: 大きな数値のモジュラー算術
2. **Keccak256**: 効率的なハッシュ化
3. **UltraHonk**: 高速ZK証明システム
4. **ERC1155**: ガス効率的なNFT標準

---

## 設定とデプロイ

### 環境変数
```typescript
VITE_SEPOLIA_RPC_URL // Sepolia RPC URL
VITE_TENDERLY_RPC_URL // Tenderly RPC URL
VITE_PUBLIC_WC_PROJECT_ID // WalletConnect Project ID
```

### 定数設定
```typescript
export const PANAGRAM_CONTRACT_ADDRESS = "" // コントラクトアドレス
export const ANSWER_HASH = "0x11212d1d1aad94d2dc18aed031902208221aa74484ac3e9122863fba27d5ca36"
export const ANAGRAM = "GELTSRAIN" // 表示用アナグラム
```

---

## 開発・テスト

### 回路開発
```bash
# Noir回路のコンパイル
nargo build

# 証明生成テスト
nargo test
```

### コントラクト開発
```bash
# テスト実行
forge test

# デプロイ
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/Panagram.sol:Panagram
```

### フロントエンド開発
```bash
# 開発サーバー起動
npm run dev

# ビルド
npm run build
```

---

## 今後の拡張可能性

1. **マルチチェーン対応**: より多くのEVMチェーンへの対応
2. **難易度調整**: 動的な問題難易度システム
3. **ランキング機能**: 全体的なリーダーボード
4. **報酬システム**: トークンベースの報酬
5. **ソーシャル機能**: フレンド機能、チーム戦

このプロジェクトは、ゼロ知識証明技術を使用したゲーミフィケーションの優れた実装例として、教育的価値が高く、Web3技術の実践的な学習に適している。