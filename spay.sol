pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev 获取代币的总供应量。
     * @return uint256 总供应量。
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 获取特定账户的代币余额。
     * @param account 账户地址。
     * @return uint256 账户代币余额。
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 将代币从消息发送者转移到接收者。
     * @param recipient 接收者地址。
     * @param amount 转移的代币数量。
     * @return bool 操作成功与否。
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev 获取授权的金额。
     * @param owner 拥有代币的账户地址。
     * @param spender 被授权的账户地址。
     * @return uint256 被授权的代币数量。
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 授权代币给指定的账户。
     * @param spender 被授权的账户地址。
     * @param amount 授权的代币数量。
     * @return bool 操作成功与否。
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 将代币从一个账户转移到另一个账户。
     * @param sender 发送者地址。
     * @param recipient 接收者地址。
     * @param amount 转移的代币数量。
     * @return bool 操作成功与否。
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev 转移事件，记录代币从一个账户转移到另一个账户。
     * @param from 发送者地址。
     * @param to 接收者地址。
     * @param value 转移的代币数量。
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev 授权事件，记录账户对另一个账户的授权。
     * @param owner 拥有代币的账户地址。
     * @param spender 被授权的账户地址。
     * @param value 授权的代币数量。
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

abstract contract Context {
    /**
     * @dev 获取消息发送者的地址。
     * @return address 消息发送者的地址。
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev 获取消息数据。
     * @return bytes calldata 消息数据。
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // 压制状态可变性警告，而不生成字节码 - 参考：https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// ERC20 合约示例
contract ERC20 is Context, IERC20 {
    // 账户余额映射
    mapping (address => uint256) private _balances;

    // 授权映射
    mapping (address => mapping (address => uint256)) private _allowances;

    // 代币总供应量
    uint256 private _totalSupply;

    // 代币名称
    string private _name;
    // 代币符号
    string private _symbol;

    /**
     * @dev 构造函数，设置代币名称和符号。
     * @param name_ 代币名称。
     * @param symbol_ 代币符号。
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev 返回代币名称。
     * @return string 代币名称。
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev 返回代币符号。
     * @return string 代币符号。
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev 返回代币的小数位数。
     * @return uint8 小数位数。
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev 获取代币的总供应量。
     * @return uint256 总供应量。
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev 获取账户的代币余额。
     * @param account 账户地址。
     * @return uint256 代币余额。
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev 将代币从消息发送者转移到接收者。
     * @param recipient 接收者地址。
     * @param amount 转移的代币数量。
     * @return bool 操作成功与否。
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev 获取授权的代币数量。
     * @param owner 拥有代币的账户地址。
     * @param spender 被授权的账户地址。
     * @return uint256 授权的代币数量。
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev 授权代币给指定账户。
     * @param spender 被授权的账户地址。
     * @param amount 授权的代币数量。
     * @return bool 操作成功与否。
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev 将代币从一个账户转移到另一个账户。
     * @param sender 发送者地址。
     * @param recipient 接收者地址。
     * @param amount 转移的代币数量。
     * @return bool 操作成功与否。
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev 增加账户的授权额度。
     * @param spender 被授权的账户地址。
     * @param addedValue 增加的授权额度。
     * @return bool 操作成功与否。
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev 减少账户的授权额度。
     * @param spender 被授权的账户地址。
     * @param subtractedValue 减少的授权额度。
     * @return bool 操作成功与否。
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev 内部方法，进行代币转移。
     * @param sender 发送者地址。
     * @param recipient 接收者地址。
     * @param amount 转移的代币数量。
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev 内部方法，铸造代币。
     * @param account 账户地址。
     * @param amount 铸造的代币数量。
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev 内部方法，销毁代币。
     * @param account 账户地址。
     * @param amount 销毁的代币数量。
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev 内部方法，设置账户的授权额度。
     * @param owner 拥有代币的账户地址。
     * @param spender 被授权的账户地址。
     * @param amount 授权的代币数量。
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev 内部方法，在代币转移前调用，可用于自定义逻辑。
     * @param from 发送者地址。
     * @param to 接收者地址。
     * @param amount 转移的代币数量。
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

pragma solidity ^0.8.0;

/**
 * @dev {ERC20} 合约的扩展，增加了代币供应量的上限。
 */
abstract contract ERC20Capped is ERC20 {
    uint256 immutable private _cap;

    /**
     * @dev 设置 `cap` 的值。此值为不可变，仅在构造期间设置一次。
     * @param cap_ 代币供应量的上限。
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev 返回代币总供应量的上限。
     * @return uint256 代币供应量的上限。
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev 重写 {ERC20-_mint} 方法，确保在铸造代币时不会超过上限。
     * @param account 接收代币的账户。
     * @param amount 铸造的代币数量。
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol

pragma solidity ^0.8.0;

/**
 * @dev 扩展了 ERC20 合约，增加了代币销毁功能。
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev 销毁调用者持有的 `amount` 代币。
     * @param amount 销毁的代币数量。
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev 销毁 `account` 持有的 `amount` 代币。
     * @param account 账户地址。
     * @param amount 销毁的代币数量。
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol

pragma solidity ^0.8.0;

/**
 * @dev 实现暂停和解除暂停功能的合约。
 */
abstract contract Pausable is Context {
    /**
     * @dev 当 `account` 触发暂停时发出事件。
     */
    event Paused(address account);

    /**
     * @dev 当 `account` 解除暂停时发出事件。
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev 初始化合约时为未暂停状态。
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev 返回合约当前是否暂停。
     * @return bool 合约暂停状态。
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev 修饰符，确保函数在合约未暂停的情况下可调用。
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev 修饰符，确保函数在合约暂停的情况下可调用。
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev 触发暂停状态。
     * 需要合约未暂停状态。
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev 解除暂停状态。
     * 需要合约处于暂停状态。
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol

pragma solidity ^0.8.0;

/**
 * @dev 扩展了 ERC20 合约，增加了暂停功能。
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev 重写 {ERC20-_beforeTokenTransfer} 方法。
     * 在代币转移前确保合约未暂停。
     * @param from 发送者地址。
     * @param to 接收者地址。
     * @param amount 转移的代币数量。
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

pragma solidity ^0.8.0;

/**
 * @dev ERC165 接口定义，用于检查合约是否支持特定接口。
 */
interface IERC165 {
    /**
     * @dev 检查合约是否支持特定的接口。
     * @param interfaceId 接口的标识。
     * @return bool 合约是否支持特定接口。
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

pragma solidity ^0.8.0;

/**
 * @dev 实现 IERC165 接口的基本实现。
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev 重写 {IERC165-supportsInterface} 方法。
     * @param interfaceId 接口的标识。
     * @return bool 合约是否支持特定接口。
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol

// 引入必要的库和合约
pragma solidity ^0.8.0;

interface IAccessControl {
    // 检查一个账户是否拥有特定角色
    function hasRole(bytes32 role, address account) external view returns (bool);
    // 获取特定角色的管理员角色
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    // 授予一个账户特定角色
    function grantRole(bytes32 role, address account) external;
    // 撤销一个账户的特定角色
    function revokeRole(bytes32 role, address account) external;
    // 放弃自己拥有的角色
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    // 角色数据结构，包含账户映射和管理员角色
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    // 角色映射
    mapping (bytes32 => RoleData) private _roles;

    // 默认管理员角色
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // 角色管理员变化事件
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    // 角色授予事件
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    // 角色撤销事件
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev 检查是否支持特定接口
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev 检查账户是否拥有特定角色
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * 获取特定角色的管理员角色
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * 授予账户特定角色
     */
    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }

    /**
     * 撤销账户特定角色
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }

    /**
     * 放弃自己拥有的角色
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }

    /**
     * 内部设置角色和账户的关系
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * 设置角色的管理员角色
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    /**
     * 授予角色给账户
     */
    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * 撤销账户特定角色
     */
    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

pragma solidity ^0.8.0;


library EnumerableSet {


    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }


    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }


    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// File: @openzeppelin/contracts/access/AccessControlEnumerable.sol

pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

// File: @openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol

pragma solidity ^0.8.0;






contract ERC20PresetMinterPauser is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// File: contracts/SPAY.sol

// contracts/MyNFT.sol
pragma solidity ^0.8.0;



contract SPAY is ERC20PresetMinterPauser, ERC20Capped {
    // 构造函数，初始化代币名称和符号，以及代币的供应上限
    constructor()
    ERC20PresetMinterPauser("SpaceY Token", "SPAY")  // 初始化代币名称和符号
    ERC20Capped(25000000 * (10**uint256(18)))  // 初始化代币的供应上限（25,000,000 SPAY）
    {}

    // 在代币转移之前的钩子函数，确保正确继承基类的行为
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);  // 调用父类的方法
    }

    // 用于铸造新的代币，并确保铸造的数量不超过供应上限
    function _mint(
        address account,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Capped) {
        super._mint(account, amount);  // 调用父类的方法
    }
}