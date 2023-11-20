import { MerkleTreeId } from '@aztec/types';

/**
 * Type alias for the nullifier tree ID.
 */
export type IndexedTreeId = MerkleTreeId.NULLIFIER_TREE;

/**
 * Type alias for the public data tree ID.
 */
export type PublicTreeId = MerkleTreeId.PUBLIC_DATA_TREE;

/**
 *  Defines tree information.
 */
export interface TreeInfo {
  /**
   * The tree ID.
   */
  treeId: MerkleTreeId;
  /**
   * The tree root.
   */
  root: Buffer;
  /**
   * The number of leaves in the tree.
   */
  size: bigint;

  /**
   * The depth of the tree.
   */
  depth: number;
}

/**
 * The current roots of the commitment trees
 */
export type CurrentTreeRoots = {
  /** Note Hash Tree root. */
  noteHashTreeRoot: Buffer;
  /** Contract data tree root. */
  contractDataTreeRoot: Buffer;
  /** L1 to L2 Messages data tree root. */
  l1Tol2MessagesTreeRoot: Buffer;
  /** Nullifier data tree root. */
  nullifierTreeRoot: Buffer;
  /** Blocks tree root. */
  blocksTreeRoot: Buffer;
  /** Public data tree root */
  publicDataTreeRoot: Buffer;
};

/** Return type for handleL2Block */
export type HandleL2BlockResult = {
  /** Whether the block processed was emitted by our sequencer */ isBlockOurs: boolean;
};
